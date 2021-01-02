+++
title = "FreeBSD Jail Creation"
date = 2020-01-01

[taxonomies]
tags = ["freebsd", "homelab"]
+++

Create a template dataset

```
zfs create -o mountpoint=/usr/local/jails zroot/jails
zfs create -p zroot/jails/template
```

Download the base files into a new directory

```
mkdir ~/jails
fetch ftp://ftp.freebsd.org/pub/FreeBSD/releases/amd64/amd64/11.1-RELEASE/base.txz -o ~/jails
```

Extract the base files into the template directory (mountpoint)

```
tar -xf ~/jails/base.txz -C /usr/local/jails/template
```

Copy the resolv.conf file from host to template so that we have working DNS resolution

```
cp /etc/resolv.conf /usr/local/jails/template/etc/resolv.conf
```

When finished, take a snapshot. Anything after the '@' symbol is the snapshot name. You can make changes to the template at any time, just make sure that you take another snapshot when you are finished and that any subsequently created jails use the new snapshot.

```
zfs snapshot zroot/jails/template@1
```

New jails can then be created by cloning the snapshot of the template dataset

```
zfs clone zroot/jails/template@1 zroot/jails/testjail
```

Add the jails configuration to /etc/jail.conf

```
# Global settings applied to all jails

interface = "re0";
host.hostname = "$name";
ip4.addr = 192.168.1.$ip;
path = "/usr/local/jails/$name";

exec.start = "/bin/sh /etc/rc";
exec.stop = "/bin/sh /etc/rc.shutdown";
exec.clean;
mount.devfs;

# Jail Definitions
testjail {
    $ip = 15;
}
```

Run the jail

```
jail -c testjail
```

View running jails

```
jls
```

Login to the jail

```
jexec testjail sh
```
