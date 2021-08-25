# Como criar um Kubernetes local e economizar com Cloud

Tip from Fabrício Veronez KubeDev:

> ```https://www.youtube.com/watch?v=T7RhDYBL88Q&t=7410s```

Sample KubApp from:

> ```git clone https://github.com/KubeDev/k8s-api-produto.git```

# Install current latest release

Get instructions on ```k3d.io```:

```
wget: wget -q -O - https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
```

or 

```
curl: curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
```

## First cluster (creation & inspection)

```
k3d cluster create cluster 
kubectl get nodes
kubectl get nodes -o wide
k3d cluster list
docker container ls
k3d cluster delete cluster
```

## Nominated cluster

```
k3d cluster create meucluster --no-lb
kubectl get nodes
docker container ls
k3d cluster delete meucluster
```

## High availiability cluster

```
k3d cluster create meucluster --servers 3 --agents 3
kubectl get nodes
kubectl apply -f ./k8s-api-produto/ -R
kubectl get services,deployments,pods
k3d cluster delete meucluster
```

## High availiability cluster with load balance

```
k3d cluster create meucluster --servers 3 --agents 1 -p "8080:30000@loadbalancer"
kubectl get nodes
kubectl apply -f ./k8s-api-produto/ -R
kubectl get services,deployments,pods
```

Try to access on ```http://<HOST IP>:8080/api-docs/```

```
k3d cluster delete meucluster
```

## That's all folks!!!
