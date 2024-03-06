# Kubernetes Multicluster with Kind and Cilium

## About

> ```https://piotrminkowski.com/2021/10/25/kubernetes-multicluster-with-kind-and-cilium/```

How to configure Kubernetes multicluster locally with Kind and Cilium.

Cilium can act as a CNI plugin on your Kubernetes cluster. It uses a Linux kernel technology called BPF, that enables the dynamic insertion of security visibility and control logic within the Linux kernel. It provides distributed load-balancing for pod to pod traffic and identity-based implementation of the NetworkPolicy resource. However, in this class, we will focus on its feature called Cluster Mesh, which allows setting up direct networking across multiple Kubernetes clusters.

Prerequisites:

1. Kind CLI
1. Cilium CLI
1. Skaffold CLI (optional)
1. Helm CLI

Source code:

- callme-service application: `https://hub.docker.com/r/piomin/callme-service`
- caller-service application: `https://hub.docker.com/r/piomin/callme-service`

## Kind Kubernetes clusters

When running a new Kind cluster we first need to disable the default CNI plugin based on kindnetd. Of course, we will use Cilium instead. Moreover, pod CIDR ranges in both our clusters must be non-conflicting and have unique IP addresses. That’s why we also provide podSubnet and serviceSubnet in the Kind cluster configuration manifest. 

- Configuration file for cluster 1: [`kind-c1-config.yaml`](./resources/kind-c1-config.yaml)
- 

Hands-on:

```sh
kind create cluster --name c1 --config ./resources/kind-c1-config.yaml

kind create cluster --name c2 --config ./resources/kind-c2-config.yaml
```

## Install Cilium CNI on Kubernetes

```sh
helm repo add cilium https://helm.cilium.io/

# Set context to kind-c1
kubectl config use-context kind-c1

helm install cilium cilium/cilium --version 1.10.5 \
  --namespace kube-system \
  --set nodeinit.enabled=true \
  --set kubeProxyReplacement=partial \
  --set hostServices.enabled=false \
  --set externalIPs.enabled=true \
  --set nodePort.enabled=true \
  --set hostPort.enabled=true \
  --set cluster.name=c1 \
  --set cluster.id=1

# Set context to kind-c2
kubectl config use-context kind-c2

helm install cilium cilium/cilium --version 1.10.5 \
  --namespace kube-system \
  --set nodeinit.enabled=true \
  --set kubeProxyReplacement=partial \
  --set hostServices.enabled=false \
  --set externalIPs.enabled=true \
  --set nodePort.enabled=true \
  --set hostPort.enabled=true \
  --set cluster.name=c2 \
  --set cluster.id=1
```

## Install MetalLB on Kind

```sh
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/master/manifests/namespace.yaml


```



