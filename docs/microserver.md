# NAS on HP Microserver Gen8

## Hardware specs

HP ProLiant G8 Microserver G1610T
                               
- Intel Celeron G1610T (dual core 2.3 GHz)     
- 16GB RAM           
- 2 x 250GB SSD
- 2 x 3TB HDD

## Summary

I previously ran FreeNAS on this Microserver, but that was installed about 6 years ago so its very out of date. I want to use this as a NAS, but Im not too bothered about running a specific NAS OS like FreeNAS/TrueNAS etc. So my plan is to install Ubuntu 20.04 (current latest LTS) onto a USB disk, then have the disks set up in zpools with ZFS.

## Setup

Whenever you search the internet for installing Ubuntu onto a USB disk it assumes you want to use it as a LiveCD from which to install Ubuntu onto the HDDs. I initially tried installing onto a USB stick by using two sticks, one for the initial boot which is placed in the USB jack inside the case, then another blank one inserted in the USB jack on the front of the case.

However for whatever reason, the subsequent USB stick didnt boot. I think just a dodgy stick.

So instead I did the same thing of booting from a USB stick inside the case, but then inserted a micro-sd card into the slot inside the case. I then selected that SD card as the disk to install to. 

In order to boot from this SD card, you need to press F9 during boot to enter the system setup. Then, I cant remember which specific option, but one of them has a list of options for booting from USB sticks which says like "Boot from internal USB drive first", "Boot from internal SD card first". You need to select the "Boot from internal SD first" option.

Then continue boot, and it should boot correctly.

## ZFS

You need to install the `zfsutils-linux` package to manage zpools.

I set up the disks so that the two SSDs were in one pool, just striped, no mirror. Then the two HDDs were in another pool, mirrored. This results in two zpools, one with 500GB and no redundancy plus one with 3TB and redundancy.

```
# Amend device names as appropriate

# SSD zpool
zpool create SSD_storage /dev/sdb /dev/sdc

# HDD zpool
zpool create HDD_storage mirror /dev/sdd /dev/sde
```
