+++
title = "Quick Multi-Node Kubernetes Cluster"
date = 2020-01-11

[taxonomies]
tags = ["k8s", "homelab"]
+++

## Quick Multi-Node Kubernetes Cluster

### Multipass

[Multipass](https://multipass.run/) lets you easily spin up Ubuntu VMs on a workstation. 

```
# Install
snap install multipass --classic
```

Then to create a new instance, just run `multipass launch`. It will create a new instance based on an Ubuntu LTS image. 

To access the instance, just run `multipass shell $name`. You then have full access to the instance. 

The instances can also be bootstrapped via [cloud-init](https://cloud-init.io/) in the same way that instances on cloud providers are.

### Microk8s

[Microk8s](https://microk8s.io) is a small Kubernetes distribution designed for appliances. 

```
# Install
sudo snap install microk8s --classic --channel=1.16/stable
sudo usermod -a -G microk8s $USER
su - $USER
```

### Cluster

So with two Multipass instances launched, and Microk8s installed on each, we can now join them together to [form a cluster](https://microk8s.io/docs/clustering) by running `microk8s.add-node` on the proposed master and then the requisite `microk8s.join` command on the other node. 

