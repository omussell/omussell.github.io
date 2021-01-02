+++
title = "NSD and Unbound config"
date = 2020-01-04

[taxonomies]
tags = ["dns", "homelab"]
+++

## NSD and Unbound config

Set up the unbound/nsd-control

```
local-unbound-setup
nsd-control-setup
```

Enable NSD and Unbound to start in `/etc/rc.conf`

```
sysrc nsd_enable="YES"
sysrc local_unbound_enable="YES"
```

Set a different listening port for NSD in `/usr/local/etc/nsd.conf`

```
server:
  port: 5353
```

Create an inital zone file `/usr/local/etc/nsd/home.lan.zone`

```
$ORIGIN home.lan. ;
$TTL 86400 ;

@ IN SOA ns1.home.lan. admin.home.lan. (
        2017080619 ;
        28800 ;
        7200 ;
        864000 ;
        86400 ;
        )

        NS ns1.home.lan.

ns1 IN A 192.168.1.15
jail IN A 192.168.1.15
```

Create the reverse lookup zone file `/usr/local/etc/nsd/home.lan.reverse`

```
$ORIGIN home.lan.
$TTL 86400

0.1.168.192.in-addr.arpa. IN SOA ns1.home.lan. admin.home.lan. (
        2017080619
        28800
        7200
        864000
        86400
        )

        NS ns1.home.lan.

15.1.168.192.in-addr.arpa. IN PTR jail
15.1.168.192.in-addr.arpa. IN PTR ns1
```

### OpenDNSSEC

Install the required packages

```
pkg install -y opendnssec softhsm
```

Set the softhsm database location in `/usr/local/etc/softhsm.conf`

```
0:/var/lib/softhsm/slot0.db
```

Initialise the token database:

```
softhsm --init-token --slot 0 --label "OpenDNSSEC"
Enter the PIN for the SO and then the USER.
```

Make sure opendnssec has permission to access the token database

```
chown opendnssec /var/lib/softhsm/slot0.db
chgrp opendnssec /var/lib/softhsm/slot0.db
```

Set some options for OpenDNSSEC in `/usr/local/etc/opendnssec/conf.xml`

```
<Repository name="SoftHSM">
        <Module>/usr/local/lib/softhsm/libsofthsm.so</Module>
        <TokenLabel>OpenDNSSEC</TokenLabel>
        <PIN>1234</PIN>
        <SkipPublicKey/>
</Repository>
```

Edit `/usr/local/etc/opendnssec/kasp.xml`. Change unixtime to datecounter in the Serial parameter. This allows us to use YYYYMMDDXX format for the SOA SERIAL values.

```
<Zone>
        <PropagationDelay>PT300S</PropagationDelay>
        <SOA>
                <TTL>PT300S</TTL>
                <Minimum>PT300S</Minimum>
                <Serial>datecounter</Serial>
        </SOA>
</Zone>
```
