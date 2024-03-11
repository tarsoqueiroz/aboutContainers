# Kubernetes Multicluster with Kind and Submariner

## About

> `https://piotrminkowski.com/2021/07/08/kubernetes-multicluster-with-kind-and-submariner/`
>
> `https://submariner.io/getting-started/quickstart/kind/`

## by piotrminkowski.com

### Create Clusters

```sh
kind create cluster --config ./resources/kind-cluster-c1.yaml
kind create cluster --config ./resources/kind-cluster-c2.yaml

kind get clusters

kubectl --context kind-c1 get nodes -o wide
kubectl --context kind-c2 get nodes -o wide
```

### Install Calico

```sh
kubectl config get-contexts

kubectl config use-context kind-c1
kubectl create -f https://docs.projectcalico.org/manifests/tigera-operator.yaml
kubectl apply -f resources/tigera-c1.yaml

kubectl config use-context kind-c2
kubectl create -f https://docs.projectcalico.org/manifests/tigera-operator.yaml
kubectl apply -f resources/tigera-c2.yaml
```

### Verifying network

```sh
kubectl --context kind-c1 get nodes -o wide
kubectl --context kind-c2 get nodes -o wide
kubectl --context kind-c1 get pod -n calico-system -o wide
kubectl --context kind-c2 get pod -n calico-system -o wide
```

### Install Submariner

```sh
docker exec -it c1-control-plane /bin/bash

# Inside c1-controle-plane
root@c1-control-plane:/# echo $KUBECONFIG

root@c1-control-plane:/# exit

docker ps | grep "plane\|worker"

docker inspect c2-control-plane -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}'
kubectl --context kind-c1 get nodes -o wide
kubectl --context kind-c2 get nodes -o wide

kubectl config use-context kind-c1

subctl deploy-broker

 ✓ Setting up broker RBAC 
 ✓ Deploying the Submariner operator
 ✓ Created operator CRDs
 ✓ Created operator namespace: submariner-operator
 ✓ Created operator service account and role
 ✓ Created submariner service account and role
 ✓ Created lighthouse service account and role
 ✓ Deployed the operator successfully
 ✓ Deploying the broker
 ✓ Saving broker info to file "broker-info.subm"
```

### Enable direct communication

```sh
kubectl label node c1-worker submariner.io/gateway=true
kubectl label node c2-worker submariner.io/gateway=true --context kind-c2

subctl join broker-info.subm --natt=false --clusterid kind-c1
subctl join broker-info.subm --natt=false --clusterid kind-c2 --context kind-c2





```

## by Devopstales

### Bootstrap kind clusters

```sh
kind create cluster --config ./resources/kind-c1-config.yaml
kind create cluster --config ./resources/kind-c2-config.yaml

kind get clusters

kubectl cluster-info --context kind-c1
kubectl --context kind-c1 get nodes -o wide

kubectl cluster-info --context kind-c2
kubectl --context kind-c2 get nodes -o wide
```

### Install Calico CNI

```sh
kubectl config use-context kind-c1
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml
kubectl apply -f ./resources/calico-cni-tigera-c1.yaml 
watch -n 1 kubectl get pods -n calico-system

kubectl config use-context kind-c2
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml
kubectl apply -f ./resources/calico-cni-tigera-c2.yaml 
watch -n 1 kubectl get pods -n calico-system
```

### Install submariner

```sh
kubectl config use-context kind-c1
kubectl label node c1-worker submariner.io/gateway=true

kubectl config use-context kind-c2
kubectl label node c2-worker submariner.io/gateway=true

kubectl config use-context kind-c1
subctl deploy-broker
subctl join broker-info.subm --natt=false --clusterid kind-c1

kubectl config use-context kind-c1
subctl join broker-info.subm --natt=false --clusterid kind-c2


```





### Continue

here