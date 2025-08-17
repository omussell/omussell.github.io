# Homelab

The homelab has evolved over time as I tried learning new things to either support my current work or build towards finding new work.

It started out with basic Linux like Debian/Ubuntu before moving to FreeBSD. That meant learning about managing services using Jails and storing data on disks with ZFS. That was then used at my next workplace.

After that it was setting up a hypervisor for running VMs and spinning up Kubernetes clusters. Running different CI systems for building images and deploying containers.

Its currently defunct and my intention is to have the hardware set up properly either in a small rack or some other kind of furniture as a more permanent solution. Its mostly been a pile of computers on the floor. I've always managed the networking by using an 8 port dumb switch. Now there will be a router, switches and fiber networking.

In addition to the networking there is also a bunch of raspberry pis which will be running all the time since they have low power usage. They will be for running services like DNS, web servers etc. when it would be preferred for them to always be accessible. Then for any heavier compute or storage testing there are the beefier intel based HP microservers which can run VMs and have lots of disk space and will be turned on as needed.
