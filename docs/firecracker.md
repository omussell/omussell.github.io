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

### Install

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

### Run

Rather than running the jailer binary manually, you can use the `--jailer` flag with firectl. Note that you must also include the `--chroot-base-dir="/srv/jailer"` flag, otherwise you get the `no such file or directory` error as per [this issue](https://github.com/firecracker-microvm/firecracker-go-sdk/issues/313).

You also need to copy or move the firectl, firecracker, and jailer binaries into a bin directory in your $PATH otherwise it complains. I copied them to /usr/local/bin

```
/usr/local/bin/firectl --kernel=/root/release-v0.25.2-x86_64/hello-vmlinux.bin --root-drive=/root/release-v0.25.2-x86_64/hello-rootfs.ext4 --jailer=/usr/local/bin/jailer --exec-file=/usr/local/bin/firecracker --id=testvm4 --chroot-base-dir="/srv/jailer"
```

Firectl also doesnt handle cleaning up the /srv/jailer/firecracker/$vm_name chroot directory when you power off the VM. So you need to clean this up manually.


## Notes from running the jailer manually

```
cp -v rootfs.ext4 /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/root/
cp -v vmlinux.bin /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/root/
ls /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/
ls /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/root/run/firecracker.socket 
ls /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/root/
```

```
curl --unix-socket /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/root/run/firecracker.socket -i   -X PUT 'http://localhost/boot-source'     -H 'Accept: application/json'             -H 'Content-Type: application/json'       -d "{
        \"kernel_image_path\": \"/root/vmlinux.bin\",
        \"boot_args\": \"console=ttyS0 reboot=k panic=1 pci=off\"
   }"
ls /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/root/vmlinux.bin 
curl --unix-socket /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/root/run/firecracker.socket -i   -X PUT 'http://localhost/boot-source'     -H 'Accept: application/json'             -H 'Content-Type: application/json'       -d "{
        \"kernel_image_path\": \"/srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/root/vmlinux.bin\",
        \"boot_args\": \"console=ttyS0 reboot=k panic=1 pci=off\"
   }"
ls -alh /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/root/
chown 1001:1111 /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/root/vmlinux.bin 
chown 1001:1111 /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/root/rootfs.ext4 
curl --unix-socket /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/root/run/firecracker.socket -i   -X PUT 'http://localhost/boot-source'     -H 'Accept: application/json'             -H 'Content-Type: application/json'       -d "{
        \"kernel_image_path\": \"/srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/root/vmlinux.bin\",
        \"boot_args\": \"console=ttyS0 reboot=k panic=1 pci=off\"
   }"
curl --unix-socket /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/root/run/firecracker.socket -i   -X PUT 'http://localhost/boot-source'     -H 'Accept: application/json'             -H 'Content-Type: application/json'       -d "{
        \"kernel_image_path\": \"/root/vmlinux.bin\",
        \"boot_args\": \"console=ttyS0 reboot=k panic=1 pci=off\"
   }"
ls -alh /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/root/
curl --unix-socket /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/root/run/firecracker.socket -i   -X PUT 'http://localhost/boot-source'     -H 'Accept: application/json'             -H 'Content-Type: application/json'       -d "{
        \"kernel_image_path\": \"/root/vmlinux.bin\",
        \"boot_args\": \"console=ttyS0 reboot=k panic=1 pci=off\"
   }"
ls -alh /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/root/
ls /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/
ls /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/root/
curl --unix-socket /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/root/run/firecracker.socket -i   -X PUT 'http://localhost/boot-source'     -H 'Accept: application/json'             -H 'Content-Type: application/json'       -d "{
        \"kernel_image_path\": \"./vmlinux.bin\",
        \"boot_args\": \"console=ttyS0 reboot=k panic=1 pci=off\"
   }"
curl --unix-socket /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/root/run/firecracker.socket -i   -X PUT 'http://localhost/drives/rootfs'   -H 'Accept: application/json'             -H 'Content-Type: application/json'       -d "{
        \"drive_id\": \"rootfs\",
        \"path_on_host\": \"./rootfs.ext4\",
        \"is_root_device\": true,
        \"is_read_only\": false
   }"
curl --unix-socket /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/root/run/firecracker.socket -i   -X PUT 'http://localhost/actions'         -H  'Accept: application/json'            -H  'Content-Type: application/json'      -d '{
      "action_type": "InstanceStart"
   }'
curl --unix-socket /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/root/run/firecracker.socket -i   -X GET 'http://localhost/'         -H  'Accept: application/json'            -H  'Content-Type: application/json'
curl --unix-socket /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/root/run/firecracker.socket -i   -X PUT 'http://localhost/actions'         -H  'Accept: application/json'            -H  'Content-Type: application/json'      -d '{
      "action_type": "InstanceStop"
   }'
curl --unix-socket /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/root/run/firecracker.socket -i   -X PUT 'http://localhost/actions'         -H  'Accept: application/json'            -H  'Content-Type: application/json'      -d '{
      "action_type": "InstanceStop"
   }'
curl --unix-socket /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/root/run/firecracker.socket -i   -X PUT 'http://localhost/actions'         -H  'Accept: application/json'            -H  'Content-Type: application/json'      -d '{
      "action_type": "SendCtrlAltDel"
   }'
curl --unix-socket /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/root/run/firecracker.socket -i   -X GET 'http://localhost/'         -H  'Accept: application/json'            -H  'Content-Type: application/json'
ps aux | grep fire
ls /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/root/
ls /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/root/run/
```

```
mkdir -p /srv/jailer
cp -v ./release-v1.1.2-x86_64/jailer-v1.1.2-x86_64 /usr/bin/jailer
ls -alh /usr/bin/jailer
ls /var/run/netns
ls /var/run
/usr/bin/jailer --id 551e7604-e35c-42b3-b825-416853441234 --exec-file /usr/bin/firecracker --daemonize
addgroup -G 1111 551e7604-e35c-42b3-b825-416853441234
addgroup ---gid 1111 551e7604-e35c-42b3-b825-416853441234
addgroup --gid 1111 551e7604
addgroup --gid 1111 551e7604-e35c-42b3-b825-416853441234
addgroup --gid 1111 551e7604
addgroup --gid 1111 5517604
addgroup --gid 1111 mygroupname
adduser
adduser myusername
/usr/bin/jailer --id 551e7604-e35c-42b3-b825-416853441234 --exec-file /usr/bin/firecracker --daemonize --uid 1001 --gid 1111
ls /usr/bin/firecracker
cp -v ./release-v1.1.2-x86_64/firecracker-v1.1.2-x86_64 /usr/bin/firecracker
/usr/bin/jailer --id 551e7604-e35c-42b3-b825-416853441234 --exec-file /usr/bin/firecracker --daemonize --uid 1001 --gid 1111
/usr/bin/jailer --id 551e7604-e35c-42b3-b825-416853441234 --exec-file /usr/bin/firecracker --uid 1001 --gid 1111 --daemonize
rm -rf /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/
/usr/bin/jailer --id 551e7604-e35c-42b3-b825-416853441234 --exec-file /usr/bin/firecracker --uid 1001 --gid 1111 --daemonize
rm -rf /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/
mkdir -p /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/
chown 1001:1111 /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/
ls -alh /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/
/usr/bin/jailer --id 551e7604-e35c-42b3-b825-416853441234 --exec-file /usr/bin/firecracker --uid 1001 --gid 1111 --daemonize
mkdir -p /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/root/
chown 1001:1111 /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/root
/usr/bin/jailer --id 551e7604-e35c-42b3-b825-416853441234 --exec-file /usr/bin/firecracker --uid 1001 --gid 1111 --daemonize
rm /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/dev/net/tun
rm -rf /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/
mkdir -p /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/root/
chown -R 1001:1111 /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/
/usr/bin/jailer --id 551e7604-e35c-42b3-b825-416853441234 --exec-file /usr/bin/firecracker --uid 1001 --gid 1111 --daemonize
/usr/bin/jailer --id 551e7604-e35c-42b3-b825-416853441234 --exec-file /usr/bin/firecracker --uid 1001 --gid 1111 
rm -rf /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/
mkdir -p /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/root/
chown -R 1001:1111 /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/
/usr/bin/jailer --id 551e7604-e35c-42b3-b825-416853441234 --exec-file /usr/bin/firecracker --uid 1001 --gid 1111 
```

```
curl --unix-socket /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/root/run/firecracker.socket -i   -X PUT 'http://localhost/boot-source'     -H 'Accept: application/json'             -H 'Content-Type: application/json'       -d "{
        \"kernel_image_path\": \"./vmlinux.bin\",
        \"boot_args\": \"console=ttyS0 reboot=k panic=1 pci=off\"
   }"
curl --unix-socket /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/root/run/firecracker.socket -i   -X PUT 'http://localhost/drives/rootfs'   -H 'Accept: application/json'             -H 'Content-Type: application/json'       -d "{
        \"drive_id\": \"rootfs\",
        \"path_on_host\": \"./rootfs.ext4\",
        \"is_root_device\": true,
        \"is_read_only\": false
   }"
curl --unix-socket /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/root/run/firecracker.socket -i   -X PUT 'http://localhost/network-interfaces/eth0'   -H 'Accept: application/json'   -H 'Content-Type: application/json'   -d '{
      "iface_id": "eth0",
      "host_dev_name": "tap0"
    }

'
curl --unix-socket /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/root/run/firecracker.socket -i   -X PUT 'http://localhost/actions'         -H  'Accept: application/json'            -H  'Content-Type: application/json'      -d '{
      "action_type": "InstanceStart"
   }'
ps aux | grep jail
ps aux | grep fire
ip addr | less
ping 10.0.0.1
ping 10.0.0.2
pkill firecracker
```

```
ip tuntap add tap0 mode tap
ip addr
ip addr | grep bond0
ip addr add 10.0.0.1/24 dev tap0
ip link set tap0 up
sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
iptables --help
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i tap0 -o eth0 -j ACCEPT
ps aux | grep fire
/usr/bin/jailer --id 551e7604-e35c-42b3-b825-416853441234 --exec-file /usr/bin/firecracker --uid 1001 --gid 1111 
rm -rf /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/root/dev
/usr/bin/jailer --id 551e7604-e35c-42b3-b825-416853441234 --exec-file /usr/bin/firecracker --uid 1001 --gid 1111 
rm -rf /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/root/run
/usr/bin/jailer --id 551e7604-e35c-42b3-b825-416853441234 --exec-file /usr/bin/firecracker --uid 1001 --gid 1111 
rm -rf /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/root/run
rm -rf /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/root/dev
/usr/bin/jailer --id 551e7604-e35c-42b3-b825-416853441234 --exec-file /usr/bin/firecracker --uid 1001 --gid 1111 
```
