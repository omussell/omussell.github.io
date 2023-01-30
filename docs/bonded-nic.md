# Creating Bonded NICs on Ubuntu 20.04

## Summary

On the HP MicroServer Gen 8 and MicroServer Gen 10+ there are four ethernet ports. I wanted to group these together into a bonded NIC so that ethernet traffic could run over all four to increase the throughput.

There are other names for bonding, like teaming or link aggregation/LACP. They all mean the same thing, multiple network ports joined together to serve traffic.

## Setup

Install the dependency:

```
apt install ifenslave
```

Load the kernel module:

```
# Check if already loaded:
lsmod | grep bonding

# If no output then:
modprobe bonding
```

This only loads the bonding kernel module while the system is running, it would be lost on reboot. Add it to the modules file to load it at boot as well:

```
vim /etc/modules

# Add the following line to the file:
bonding

```

Find the network interfaces. You can do this in a few different ways, an easy way is just:

```
ip addr
```

Which lists all of your network interfaces. `lo` is for loopback, then the others will be your ethernet interfaces. This can differ between different NIC manufacturers. On this machine, its returning names like `eno1`, `eno2` etc. Sometimes it is like `enp2s0` or `enp3s0` instead.

Edit the netplan config file to add the config. You will need to know the IP address of your gateway/router and the IP addresses for the DNS nameservers. For me, the router IP is `192.168.0.1` and the DNS servers are `192.168.0.15` (Rpi) and `1.1.1.1` (Cloudflare).

Also, I've set the bonded NIC to use DHCP to configure its IP address. I'm also using all available `eno*` ethernet ports in the bond. If you want to use a specific set of ports instead, check out the [netplan documentation](https://netplan.io/examples/)

```
vim /etc/netplan/00-installer-config.yaml

network:
  version: 2
  ethernets:
    eports:
      match:
        name: eno*
      optional: true
  bonds:
    bond0:
      interfaces: [eports]
      dhcp4: true
      gateway4: 192.168.0.1
      nameservers:
        addresses: [192.168.0.15, 1.1.1.1]
      parameters:
        mode: 802.3ad
        lacp-rate: fast
        mii-monitor-interval: 100
```

Apply the changes:

```
netplan apply
```

If you lose your SSH connection, something went wrong, or DHCP has just decided to give it a different IP address than what you used to connect. Its a good idea to have out of band management or a spare keyboard+monitor plugged in if the network stops working.

## End result

If you run `ip addr` again, you can now see a new network interface has been created called `bond0`, which is the master. Then the `eno*` interfaces have been added as slaves of `bond0`.

```
root@dixie:~# ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eno1: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc mq master bond0 state UP group default qlen 1000
    link/ether de:d5:c6:da:5b:a0 brd ff:ff:ff:ff:ff:ff
3: eno2: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc mq master bond0 state UP group default qlen 1000
    link/ether de:d5:c6:da:5b:a0 brd ff:ff:ff:ff:ff:ff
4: eno3: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc mq master bond0 state UP group default qlen 1000
    link/ether de:d5:c6:da:5b:a0 brd ff:ff:ff:ff:ff:ff
5: eno4: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc mq master bond0 state UP group default qlen 1000
    link/ether de:d5:c6:da:5b:a0 brd ff:ff:ff:ff:ff:ff
6: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether de:d5:c6:da:5b:a0 brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.21/24 brd 192.168.0.255 scope global dynamic bond0
       valid_lft 84976sec preferred_lft 84976sec
    inet6 fe80::dcd5:c6ff:feda:5ba0/64 scope link 
       valid_lft forever preferred_lft forever
```
