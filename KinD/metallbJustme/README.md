# [ Kube 43.1 ] Deploying & Using MetalLB in KinD Kubernetes Cluster

> `https://www.youtube.com/watch?v=zNbqxPRTjFg`

```Shell
figlet "MetalLB in KinD"
kind create cluster --config ./kind-config.yaml 

kind get clusters 
kind get nodes --name justme

kubectl cluster-info 
kubectl get nodes -o wide
kubectl -n kube-system get all


kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.11.0/manifests/namespace.yaml
kubectl get ns
kubectl -n metallb-system get all

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.11.0/manifests/metallb.yaml
kubectl -n metallb-system get all

kubectl get nodes -o wide
ip -br -c a
pico metallb.yaml

kubectl create  -f ./metallb.yaml 
kubectl get all

kubectl create deploy nginx --image nginx
kubectl expose deploy nginx --port 80 --type LoadBalancer
kubectl get all 
curl 172.23.171.1

kubectl create deploy nginx2 --image nginx
kubectl expose deploy nginx2 --port 80 --type LoadBalancer
kubectl get all 
curl 172.23.171.2
```

- Addon

```Shell
kubectl apply -f ./foo-deploy.yaml 
kubectl apply -f ./foo-service.yaml 
curl 172.23.171.3

kubectl apply -f ./deu-deploy.yaml 
kubectl apply -f ./deu-service.yaml 
curl 172.23.171.4:8080
```

- LoadBalance IP Fix

> `https://docs.okd.io/4.9/networking/metallb/metallb-configure-services.html`

