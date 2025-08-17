# Hardware

The homelab has evolved over time as I tried learning new things to either support my current work or build towards finding new work.

It started out with basic Linux like Debian/Ubuntu before moving to FreeBSD. That meant learning about managing services using Jails and storing data on disks with ZFS. That was then used at my next workplace.

After that it was setting up a hypervisor for running VMs and spinning up Kubernetes clusters. Running different CI systems for building images and deploying containers.

Its currently defunct and my intention is to have the hardware set up properly either in a small rack or some other kind of furniture as a more permanent solution. Its mostly been a pile of computers on the floor. I've always managed the networking by using an 8 port dumb switch. Now there will be a router, switches and fiber networking.

In addition to the networking there is also a bunch of raspberry pis which will be running all the time since they have low power usage. They will be for running services like DNS, web servers etc. when it would be preferred for them to always be accessible. Then for any heavier compute or storage testing there are the beefier intel based HP microservers which can run VMs and have lots of disk space and will be turned on as needed.

### Gigabyte Brix Pro GB-BXI7-4770R

-   Intel Core i7-4770R (quad core 3.2GHz)
-   16GB RAM
-   250GB mSATA SSD
-   250GB 2.5 inch SSD

### HP ProLiantGen10 Plus Microserver

- Intel Xeon E-2224 4 Core Processor
- 16GB RAM
- 2 x 250GB SSD

### HP ProLiant G8 Microserver G1610T

-   Intel Celeron G1610T (dual core 2.3 GHz)
-   16GB RAM
-   2 x 3TB HDD
-   2 x 4TB HDD

### Raspberry Pi 2 Model B

- Quad core
- 1GB RAM
- 8GB MicroSD

### Raspberry Pi 4 Model B

- Quad core
- 4GB RAM
- 16GB MicroSD

### 3 x Raspberry Pi 5

- Quad core
- 8GB RAM
- 32GB MicroSD
- 256GB NVME

### 1 x Raspberry Pi 5

- Quad core
- 8GB RAM
- 32GB MicroSD
- Hailo 13 TOPS

### 1 x Raspberry Pi 5

- Quad core
- 8GB RAM
- 32GB MicroSD
- Dual NVME HAT
- 2 x 512GB NVME


### Networking

- MikroTik 5009UG+ Compact Rackmount 9 Port Router
- MikroTik CSS318 Cloud Smart Switch - CSS318-16G-2S+IN
- Mikrotik Rack-holder 19inch 10U Adjustable Desktop Rack
- MikroTik SFP+ Direct Attach Active Optics Cable 5m - S+AO0005
