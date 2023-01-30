# Bhyve VM Creation

### Bhyve Initial Setup

Enable the tap interface in `/etc/sysctl.conf` and load it on the currently running system

```
net.link.tap.up_on_open=1
sysctl -f /etc/sysctl.conf
```

Enable bhyve, serial console and bridge/tap interface kernel modules in `/boot/loader.conf`. Reboot to apply changes or use kldload.

```
vmm_load="YES"
nmdm_load="YES"
if_bridge_load="YES"
if_tap_load="YES"
```

Set up the network interfaces in `/etc/rc.conf`

```
cloned_interfaces="bridge0 tap0"
ifconfig_bridge0="addm re0 addm tap0"
```

Create a ZFS volume

```
zfs create -V16G -o volmode=dev zroot/testvm
```

Download the installation image

```
fetch ftp://ftp.freebsd.org/pub/FreeBSD/releases/ISO-IMAGES/11.1/FreeBSD-11.1-RELEASE-amd64-disc1.iso 
```

Start the VM

```
sh /usr/share/examples/bhyve/vmrun.sh -c 1 -m 512M -t tap0 -d /dev/zvol/zroot/testvm -i -I FreeBSD-11.1-RELEASE-amd64-disc1.iso testvm
```

Install as normal, following the menu options

### New VM Creation Script

```
#! /bin/sh
read -p "Enter hostname: " hostname
zfs create -V16G -o volmode=dev zroot/$hostname
sh /usr/share/examples/bhyve/vmrun.sh -c 1 -m 512M -t tap0 -d /dev/zvol/zroot/$hostname -i -I ~/FreeBSD-11.1-RELEASE-amd64-disc1.iso $hostname
```

### Creating a Linux guest

Create a file for the hard disk

```
truncate -s 16G linux.img
```

Create the file to map the virtual devices for kernel load

```
~/device.map

(hd0) /root/linux.img
(cd0) /root/linux.iso
```

Load the kernel

```
grub-bhyve -m ~/device.map -r cd0 -M 1024M linuxguest
```

Grub should start, choose install as normal

Start the VM

```
bhyve -A -H -P -s 0:0,hostbridge -s 1:0,lpc -s 2:0,virtio-net,tap0 -s 3:0,virtio-blk,/root/linux.img -l com1,/dev/nmdm0A -c 1 -m 512M linuxguest
```

Access through the serial console

```
cu -l /dev/nmdm0B
```


### pfSense in a VM

Download the pfSense disk image from the website using fetch

```
fetch https://frafiles.pfsense.org/mirror/downloads/pfSense-CE-2.3.1-RELEASE-2g-amd64-nanobsd.img.gz -o ~/pfSense.img.gz
```

Create the storage

```
zfs create -V2G -o volmode=dev zroot/pfsense
```

Unzip the file, and redirect output to the storage via dd

```
gzip -dc pfSense.img.gz | dd of=/dev/zvol/zroot/pfsense obs=64k
```

Load the kernel and start the boot process

```
bhyveload -c /dev/nmdm0A -d /dev/zvol/zroot/pfsense -m 256MB pfsense
```

Start the VM

```
/usr/sbin/bhyve -c 1 -m 256 -A -H -P -s 0:0,hostbridge -s 1:0,virtio-net,tap0 -s 3:0,ahci-hd,/dev/zvol/zroot/pfsense -s 4:1,lpc -l com1,/dev/nmdm0A pfsense
```

Connect to the VM via the serial connection with nmdm

```
cu -l /dev/nmdm0B
```

Perform initial configuration through the shell to assign the network interfaces

Once done, use the IP address to access through the web console 

When finished, you can shutdown/reboot

To de-allocate the resources, you need to destroy the VM

```
bhyvectl --destroy --vm=pfsense
```


### Multiple VMs using bhyve

To allow networking on multiple vms, there should be a tap assigned to each vm, connected to the same bridge. 

```
cloned_interfaces="bridge0 tap0 tap1 tap2"
ifconfig_bridge0="addm re0 addm tap0 addm tap1 addm tap2"
```

Then when you provision vms, assign one of the tap interfaces to them.

### vm-bhyve

A better way for managing a bhyve hypervisor.

Follow the instructions on the repo.

When adding the switch to a network interface, it doesn't work with re0. tap1 works, but then internet doesnt work in the VMs. Needs sorting.

zfs 

bsd-cloud-init should be tested, it sets hostname based on openstack image name.

otherwise, if we figure out how to make a template VM, you could set the hostname as part of transferring over the rc.conf file

create template VM, start it, zfs send/recv?
