+++
title = "Firecracker"
date = 2021-12-09

[taxonomies]
tags = ["homelab"]
+++

# Firecracker

[Firecracker](https://github.com/firecracker-microvm/firecracker) - Secure and fast microVMs for serverless computing.

## Quickstart

[Quickstart](https://github.com/firecracker-microvm/firecracker/blob/main/docs/getting-started.md)

### Get firecracker

```
release_url="https://github.com/firecracker-microvm/firecracker/releases"
latest=$(basename $(curl -fsSLI -o /dev/null -w  %{url_effective} ${release_url}/latest))
curl -L ${release_url}/download/${latest}/firecracker-${latest}-x86_64.tgz | tar -xz

```

### Get the kernel and rootfs

```
# Official instructions

dest_kernel="hello-vmlinux.bin"
dest_rootfs="hello-rootfs.ext4"
image_bucket_url="https://s3.amazonaws.com/spec.ccfc.min/img/quickstart_guide/x86_64"


kernel="${image_bucket_url}/kernels/vmlinux.bin"
rootfs="${image_bucket_url}/rootfs/bionic.rootfs.ext4"

curl -fsSL -o $dest_kernel $kernel
curl -fsSL -o $dest_rootfs $rootfs



# Same but with a recently built image as gleaned from the bucket list
dest_kernel="hello-vmlinux.bin"
dest_rootfs="hello-rootfs.ext4"
kernel="https://s3.amazonaws.com/spec.ccfc.min/img-dev/x86_64/ubuntu/kernel/vmlinux.bin"
rootfs="https://s3.amazonaws.com/spec.ccfc.min/img-dev/x86_64/ubuntu/fsfiles/bionic.rootfs.ext4"
curl -fsSL -o $dest_kernel $kernel
curl -fsSL -o $dest_rootfs $rootfs
```

## Using firectl

### Get firectl

```
curl -Lo firectl https://firectl-release.s3.amazonaws.com/firectl-v0.1.0
chmod +x firectl
```

### Create microvm

```
./firectl \
  --kernel=hello-vmlinux.bin \
  --root-drive=hello-rootfs.ext4
```

## Using the API

### Set the guest kernel

```
kernel_path=$(pwd)"/hello-vmlinux.bin"

curl --unix-socket /tmp/firecracker.socket -i \
  -X PUT 'http://localhost/boot-source'   \
  -H 'Accept: application/json'           \
  -H 'Content-Type: application/json'     \
  -d "{
        \"kernel_image_path\": \"${kernel_path}\",
        \"boot_args\": \"console=ttyS0 reboot=k panic=1 pci=off\"
   }"
```

### Set the guest rootf

```
rootfs_path=$(pwd)"/hello-rootfs.ext4"
curl --unix-socket /tmp/firecracker.socket -i \
  -X PUT 'http://localhost/drives/rootfs' \
  -H 'Accept: application/json'           \
  -H 'Content-Type: application/json'     \
  -d "{
        \"drive_id\": \"rootfs\",
        \"path_on_host\": \"${rootfs_path}\",
        \"is_root_device\": true,
        \"is_read_only\": false
   }"
```

### Start the guest machine

```
curl --unix-socket /tmp/firecracker.socket -i \
  -X PUT 'http://localhost/actions'       \
  -H  'Accept: application/json'          \
  -H  'Content-Type: application/json'    \
  -d '{
      "action_type": "InstanceStart"
   }'
```

## Compile Kernel and FS manually

Follow the steps in [here](https://github.com/firecracker-microvm/firecracker/blob/master/docs/rootfs-and-kernel-setup.md) to compile the kernel and base file. 

On Ubuntu when compiling you need to install dependencies like libssl-dev, libncurses-dev, bison, autoconf.

Then if you try and compile and it complains about auto.conf not existing, run make menuconfig, then exit out immediately. That seems to have sorted it.

Then when you run make vmlinux it asks lots of questions, but by using the preexisting config file from the repo a lot has already been decided. You could probably pipe yes into this, or otherwise just hold enter. Someone with more kernel experience needs to go over those options and decide if they're necessary. 

Once compiled continue with the getting started instructions but change the path to the kernel file to the vmlinux you created.

I compiled 5.4 kernel and used the existing alpine base from the getting started and it boots just fine.



## Using the jailer

The jailer is used to provide additional isolation for the VMs.

The jailer binary is included in the tgz file from the firecracker release.

```
# It needs to be built statically linked to musl.

apt install -y musl-tools

# install rust via rustup

# cd into the jailer directory in the firecracker repo
cargo build --target="x86_64-unknown-linux-musl" --release

# the built binary gets created at:
../../build/cargo_target/x86_64-unknown-linux-musl/release/jailer

# you should probably build with tools/devtool build instead
```
