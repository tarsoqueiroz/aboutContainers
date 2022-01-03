# KinD

  > `https://kind.sigs.k8s.io`

## Install & first tests

  > `https://kind.sigs.k8s.io/docs/user/quick-start/#installation`

```Shell
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64

chmod +x ./kind

sudo install -o root -g root -m 0755 kind /usr/local/bin/kind
sudo ln -s /usr/local/bin/kind /usr/bin/kind

kind completion bash | sudo tee /etc/bash_completion.d/kind-bash

kind --version

kind create cluster 
kind get clusters 
kind create cluster --name kind-2
kind get clusters 
kubectl get nodes -o wide
kubectl cluster-info --context kind-kind
kubectl cluster-info --context kind-kind-2
kind delete cluster
kind get clusters 
kind delete cluster --name kind-2
kind get clusters 
```
