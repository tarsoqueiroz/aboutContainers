# Kubernetes Multicluster with Kind and Submariner

## About

> `https://piotrminkowski.com/2021/07/08/kubernetes-multicluster-with-kind-and-submariner/`
>
> `https://submariner.io/getting-started/quickstart/kind/`
>
> `https://devopstales.github.io/home/cluster-mesh-with-submariner/`

## Install `subctl`

Install `subctl` command line:

```sh
# Get subctl cli
curl -Ls https://get.submariner.io | bash

sudo install -o root -g root -m 0755 ~/.local/bin/subctl /usr/local/bin/subctl

subctl version
```

Completion for `subctl`:

```sh
subctl completion bash | sudo tee /etc/bash_completion.d/subctl_completion

source ~/.bashrc
```

## Create kind Clusters

To create kind clusters, run:

```sh
kind create cluster --config ./resources/kind-c1-config.yaml
kind create cluster --config ./resources/kind-c2-config.yaml

kind get clusters

kubectl cluster-info --context kind-c1
kubectl --context kind-c1 get nodes -o wide
kubectl cluster-info --context kind-c2
kubectl --context kind-c2 get nodes -o wide
```

## Install Calico CNI

```sh
kubectl config use-context kind-c1
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml
kubectl apply -f ./resources/calico-cni-tigera-c1.yaml 
kubectl get pods -n calico-system

kubectl config use-context kind-c2
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml
kubectl apply -f ./resources/calico-cni-tigera-c2.yaml 
kubectl get pods -n calico-system

kubectl get pods -n calico-system --context kind-c1 
kubectl get pods -n calico-system --context kind-c2
```

## Install submariner

```sh
kubectl --context kind-c1 label node c1-worker submariner.io/gateway=true

kubectl --context kind-c2 label node c2-worker submariner.io/gateway=true

subctl deploy-broker --context kind-c1

subctl join --context kind-c1 broker-info.subm --clusterid cluster1 --natt=false
subctl join --context kind-c2 broker-info.subm --clusterid cluster2 --natt=false

kubectl --context kind-c1 get pod -n submariner-operator
kubectl --context kind-c2 get pod -n submariner-operator
```

## Verify installation

```sh
subctl show gateways

kubectl --context kind-c2 get pod -n submariner-operator

subctl show gateways 

subctl verify --context kind-c1 --tocontext kind-c2 --only service-discovery,connectivity --verbose
subctl verify --context kind-c1 --tocontext kind-c2 --only service-discovery,connectivity
subctl verify --context kind-c2 --tocontext kind-c1 --only service-discovery,connectivity
```

## Simple sample

```sh
kubectl --context kind-c2 create deployment nginx --image=nginx
kubectl --context kind-c2 expose deployment nginx --port=80
kubectl --context kind-c2 describe service nginx
subctl export service --context kind-c2 --namespace default nginx

kubectl --context kind-c2 create deployment nginxh --image=nginx
kubectl --context kind-c2 expose deployment nginxh --port=80 --cluster-ip=None
kubectl --context kind-c2 describe service nginxh
subctl export service --context kind-c2 --namespace default nginxh

kubectl --context kind-c1 -n default run tmp-shell --rm -i --tty --image quay.io/submariner/nettest -- /bin/bash

curl nginx.default.svc.cluster.local
curl nginxh.default.svc.cluster.local

curl nginx.default.svc.clusterset.local
curl nginxh.default.svc.clusterset.local

kubectl --context kind-c2 -n default run tmp-shell --rm -i --tty --image quay.io/submariner/nettest -- /bin/bash

curl nginx.default.svc.cluster.local
curl nginxh.default.svc.cluster.local

curl nginx.default.svc.clusterset.local
curl nginxh.default.svc.clusterset.local
```

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





kind create cluster --config ./resources/kind-c1-config.yaml
kind create cluster --config ./resources/kind-c2-config.yaml

kind get clusters

kubectl cluster-info --context kind-c1
kubectl --context kind-c1 get nodes -o wide
kubectl cluster-info --context kind-c2
kubectl --context kind-c2 get nodes -o wide

kubectl config use-context kind-c1
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml
kubectl apply -f ./resources/calico-cni-tigera-c1.yaml 
kubectl get pods -n calico-system
watch -n 1 kubectl get pods -n calico-system

kubectl config use-context kind-c2
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml
kubectl apply -f ./resources/calico-cni-tigera-c2.yaml 
kubectl get pods -n calico-system
watch -n 1 kubectl get pods -n calico-system

kubectl get pods -n calico-system --context kind-c1 
kubectl get pods -n calico-system --context kind-c2



kubectl config use-context kind-c1
kubectl label node c1-worker submariner.io/gateway=true

kubectl config use-context kind-c2
kubectl label node c2-worker submariner.io/gateway=true




subctl deploy-broker --kubeconfig ~/.kube/config --context kind-c1

subctl join --kubeconfig ~/.kube/config --context kind-c1 broker-info.subm --clusterid cluster1 --natt=false
subctl join --kubeconfig ~/.kube/config --context kind-c2 broker-info.subm --clusterid cluster2 --natt=false

kubctl get pod -n submariner-operator --context kind-c1
kubctl get pod -n submariner-operator --context kind-c2

subctl show gateways 

kubctl get pod -n submariner-operator --context kind-c2
watch -n 1 kubectl get pod -n submariner-operator --context kind-c2

subctl show gateways 

subctl verify --context kind-c1 --tocontext kind-c2 --only service-discovery,connectivity --verbose
subctl verify --context kind-c1 --tocontext kind-c2 --only service-discovery,connectivity
subctl verify --context kind-c2 --tocontext kind-c1 --only service-discovery,connectivity

kubectl --context kind-c2 create deployment nginx --image=nginx
kubectl --context kind-c2 expose deployment nginx --port=80
kubectl --context kind-c2 describe service nginx
subctl export service --context kind-c2 --namespace default nginx

kubectl --context kind-c2 create deployment nginxh --image=nginx
kubectl --context kind-c2 expose deployment nginxh --port=80 --cluster-ip=None
kubectl --context kind-c2 describe service nginxh
subctl export service --context kind-c2 --namespace default nginxh

kubectl --context kind-c1 -n default run tmp-shell --rm -i --tty --image quay.io/submariner/nettest -- /bin/bash

curl nginx.default.svc.cluster.local
curl nginxh.default.svc.cluster.local
curl nginx.default.svc.clusterset.local
curl nginxh.default.svc.clusterset.local

kubectl --context kind-c2 -n default run tmp-shell --rm -i --tty --image quay.io/submariner/nettest -- /bin/bash

curl nginx.default.svc.cluster.local
curl nginxh.default.svc.cluster.local
curl nginx.default.svc.clusterset.local
curl nginxh.default.svc.clusterset.local
```





### Continue

here