# LXC/LXD Containers

You should have either a blank disk or an existing zpool for storage. Run `lxd init`, answer the questions with Yes for the most part. Enter either the disk name like `/dev/sdb` or the zpool name `tank` when prompted.

Once complete, you can start up an Alpine container with 

```
lxc launch images:alpine/3.12 alpinecontainer
``` 

or a Ubuntu container with 

```
lxc launch ubuntu:20.04 ubuntucontainer
```

You can then connect to the container with 

```
lxc exec alpinecontainer -- /bin/sh
``` 

or 

```
lxc exec ubuntucontainer -- /bin/bash
```
