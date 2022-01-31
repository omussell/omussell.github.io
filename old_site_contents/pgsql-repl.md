+++
title = "PostgreSQL 10.1 with replication"
date = 2020-01-06

[taxonomies]
tags = ["databases", "homelab"]
+++

## PostgreSQL 10.1 with replication

```
pkg install -y postgresql10-server postgresql10-client
sysrc postgresql_enable=YES
service postgresql initdb
service postgresql start
```

### PostgreSQL 10.1 SCRAM Authentication

```
su - postgres
psql
set password_encryption = 'scram-sha-256';
create role app_db with password 'foo';
select substring(rolpassword, 1, 14) from pg_authid where rolname = 'app_db';
```

### PostgreSQL 10.1 using repmgr for database replication, WAL-G for WAL archiving, and minio for S3 compatible storage

For this, I created two bhyve VMs to host postgresql and a jail on the host for minio

Make sure postgresql is running

Carry out the following steps on both primary and replicas

The current packaged version of repmgr is 3.3.1 which isn't the latest. The latest is 4.0.1, so we need to compile it ourself, and put files into the correct locations

```
fetch https://repmgr.org/download/repmgr-4.0.1.tar.gz
tar -zvxf repmgr-4.0.1.tar.gz
./configure
pkg install -y gmake
gmake
```

Copy the repmgr files to their correct locations

```
cp -v repmgr /var/db/postgres
cp -v repmgr--4.0.sql /usr/local/share/postgresql/extension/
cp -v repmgr.control /usr/local/share/postgresql/extension
```


```
vim /var/db/postgrs/data10/postgresql.conf 
```

Add lines: 

```
include_dir = 'postgresql.conf.d'
listen_addresses = '\*'
```

```
vim /var/db/postgres/data10/postgresql.conf.d/postgresql.replication.conf
```

Add lines:

```
max_wal_senders = 10
wal_level = 'replica'
wal_keep_segments = 5000
hot_standby = on
archive_mode = on
archive_command = 'wal-g stuff here'
```

vim /var/db/postgres/data10/pg_hba.conf

Add lines:
Please note, for testing purposes, these rules are wide open and allow everything. Dont do this in production, use a specific role with a password and restrict to a specific address

```
local	all		all			trust
host	all		all	0.0.0.0/0	trust
host	replication	all	0.0.0.0/0	trust
```

vim /usr/local/etc/repmgr.conf

Add lines:

```
node_id=1 # arbitrary number, each node needs to be unique
node_name=postgres-db1 # this nodes hostname
conninfo='host=192.168.1.10 user=repmgr dbname=repmgr' # the host value should be a hostname if DNS is working
```

On the primary

```
su - postgres
createuser -s repmgr
createdb repmgr -O repmgr

repmgr -f /usr/local/etc/repmgr.conf primary register
repmgr -f /usr/local/etc/repmgr.conf cluster show
```

On a standby

```
su - postgres
psql 'host=node1 user=repmgr dbname=repmgr'
```

To clone the primary, the data directory on the standby node must exist but be empty

```
rm -rf /var/db/postgres/data10/
mkdir -p /var/db/postgres/data10
chown postgres:postgres /var/db/postgres/data10
```

Dry run first to check for problems

`repmgr -h node1 -U repmgr -d repmgr -f /usr/local/etc/repmgr.conf standby clone --dry-run`

If its ok, run it

`repmgr -h node1 -U repmgr -d repmgr -f /usr/local/etc/repmgr.conf standby clone`

On the primary

```
su - postgres
psql -d repmgr
select * from pg_stat_replication;
```

On the standby

```
repmgr -f /usr/local/etc/repmgr.conf standby register
repmgr -f /usr/local/etc/repmgr.conf cluster show
```

Install minio

```
pkg install -y minio
sysrc minio_enable=YES
sysrc minio_disks=/home/user/test
mkdir -p /home/user/test
chown minio:minio /home/user/test
service minio start
# The access keys are in /usr/local/etc/minio/config.json
# You can change them in this file and restart the service to take effect
```

On the primary
WAL-G

```
pkg install -y go
mkdir -p /root/go
setenv GOPATH /root/go
cd go
go get github.com/wal-g/wal-g
cd src/github.com/wal-g/wal-g
make all
make install
cp /root/go/bin/wal-g /usr/local/bin
```

WAL-G requires certain environment variables to be set. This can be done using envdir, part of the daemontools package

pkg install -y daemontools

Setup is now complete. 

For operations, a base backup needs to be taken on a regular basis probably via a cron job, running the following command as postgres user

`wal-g backup-push /var/db/postgres/data10`

Then the archive_command in the postgresql.replication.conf should be set to the wal-push command

`wal-g wal-push /var/db/postgres/data10`

To restore, backup-fetch and wal-fetch can be used to pull the latest base backup and the necessary wal logs to recover to the latest transaction


