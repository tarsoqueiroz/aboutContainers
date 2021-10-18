# Rancher K3D - Persistent Volumes

Tip from [Just me and Opensource](https://www.youtube.com/channel/UC6VkhPuCCwR_kG0GExjoozg):

> ```https://www.youtube.com/watch?v=tjnXydnStS4```

Github:

> ```https://github.com/justmeandopensource/kubernetes```

## Creating a directory for store

```shell
mkdir <RELATIVE PATH>/kube
```

## Starting a cluster with K3d

```shell
kubectl version --short
k3d cluster create pervol --servers 1 --agents 2 --volume <RELATIVE PATH>/kube:/kube
k3d cluster list
k3d node list
kubectl get nodes
kubectl get pv,pvc
touch <RELATIVE PATH>/kube/hellok3d
ll <RELATIVE PATH>/kube
docker container ls
docker exec k3d-pervol-server-0 ls /kube
docker exec k3d-pervol-agent-0 ls /kube
docker exec k3d-pervol-agent-1 ls /kube
```

## Deploying volumes and pods

```shell
kubectl get all
kubectl create -f ./kubernetes/yamls/4-pv-hostpath.yaml -f ./kubernetes/yamls/4-pvc-hostpath.yaml -f ./kubernetes/yamls/4-busybox-pv-hostpath.yaml 
kubectl get pv,pvc
kubectl get pods
kubectl exec -it busybox sh
```

## Execute this commands inside the container

```shell
cd /mydata
ls -la
touch otherfile
exit
```

## Deleting and recreate the pode

```shell
kubectl delete pod busybox
kubectl get pods
kubectl get pv,pvc
kubectl create -f ./kubernetes/yamls/4-busybox-pv-hostpath.yaml 
kubectl get pods
kubectl exec -it busybox sh
```

## Execute this commands inside the container

```shell
cd /mydata
ls -la
touch otherfile
exit
```

## Deleting the cluster

```shell
kubectl delete -f ./kubernetes/yamls/4-pv-hostpath.yaml -f ./kubernetes/yamls/4-pvc-hostpath.yaml -f ./kubernetes/yamls/ -f 4-busybox-pv-hostpath.yaml
kubectl get pods,pv,pvc
k3d cluster delete pervol
k3d cluster list
```

## That's all folks!!!
