# tq Start

## Installing

> **NOTE:** for last release, consult:
>
> - [Releases](https://github.com/kubernetes-sigs/kind/releases); or
> - [Installing From Release Binaries](https://kind.sigs.k8s.io/docs/user/quick-start/#installing-from-release-binaries).

```sh
## Download
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.19.0/kind-linux-amd64
## Adjust and move
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
## Completion
kind completion bash | sudo tee /etc/bash_completion.d/kind-bash
```

## First tests

```sh
## First cluster creation
kind create cluster 
kind get clusters
kubectl cluster-info
kind get nodes

## Second cluster creation
kind create cluster --name kind-2
kind get clusters 
kubectl get nodes -o wide
kubectl cluster-info --context kind-kind
kubectl cluster-info --context kind-kind-2

## Removing clusters
kind delete cluster
kind get clusters 
kind delete cluster --name kind-2
kind get clusters

## Fast and furious creation and deletion
kind create cluster 
kind create cluster --name unknownotips
kind create cluster --name todelete

kind get clusters 

kubectl cluster-info --context kind-kind
kubectl cluster-info --context kind-todelete
kubectl cluster-info --context kind-unknownnotips

kubectl get nodes --context kind-kind
kubectl get nodes --context kind-todelete
kubectl get nodes --context kind-unknownnotips

kind delete clusters $(kind get clusters)
kind get clusters 
```

## Config file and Mutiples nodes

Use this config file [`kind-4node.yaml`](kind-4nodes.yaml).

Then, go create a cluster called `kind-unknownnotips`:

```sh
## Cluster creation
kind create cluster --name unknownnotips --config ./kind-4nodes.yaml 

## Get info about cluster
kind get clusters 
kind get nodes --name unknownnotips
kubectl get nodes -o wide

## Showing Docker's containers
docker ps -as

## Deleting cluster
kind delete cluster --name unknownnotips
```
