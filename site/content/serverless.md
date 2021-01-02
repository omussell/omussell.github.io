+++
title = "Serverless with Knative running in gVisor sandbox on Minikube"
date = 2020-01-12

[taxonomies]
tags = ["k8s", "homelab"]
+++

## Serverless with Knative running in gVisor sandbox on Minikube

- [Minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/) - A Kubernetes distribution which starts a single-node cluster
- [gVisor](https://gvisor.dev) - A user-space kernel, written in Go, that implements a substantial portion of the Linux system call interface.
- [Knative](https://knative.dev/) - Run serverless services on Kubernetes

Install Minikube as described in the documentation.

Install gVisor as per [the docs](https://github.com/kubernetes/minikube/blob/master/deploy/addons/gvisor/README.md):

```
minikube start --container-runtime=containerd  \
    --docker-opt containerd=/var/run/containerd/containerd.sock
minikube addons enable gvisor
kubectl get pod,runtimeclass gvisor -n kube-system
```
