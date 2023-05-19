# NGINX Ingress Controller em seu cluster Kubernetes

by Fabrício Veronez KubeDev

> `https://www.youtube.com/watch?v=mdwYc08Qr0s`

Nem sempre é correto utilizar serviços do tipo LoadBalancer ou NodePort para externalizar nossas aplicações em um cluster Kubernetes.

Pois além de acabar custando mais, perdemos alguns benefícios como roteamento baseado em domínios e outras vantagens de um proxy reverso.

Pra serviços que utilizam HTTP ou HTTPs o mais recomendado é utilizarmos o Ingress Controller, e nesse vídeo veremos como instalar e configurar na prática.

## Infra by K3d

```Shell
k3d cluster create -c infra/nginxingressctrl.yaml
kubectl cluster-info 
kubectl get nodes -o wide
```

## Deployments and Services

Now, it's time to create deployments and services:

```Shell
kubectl apply -f blue-deploy.yaml 
kubectl apply -f green-deploy.yaml 
kubectl apply -f blue-service.yaml 
kubectl apply -f green-service.yaml 
```

## Ingress

```Shell
kubectl apply -f ingress-by-subdirectory.yaml 
kubectl apply -f ingress-by-subdomain.yaml 
kubectl get ingress --all-namespaces
```

Comment `type: LoadBalancer` on manifests, delete and re-apply.

```Shell
kubectl get ingress,services -o wide
kubectl delete -f blue-service.yaml -f green-service.yaml 
kubectl apply -f blue-service.yaml -f green-service.yaml 
kubectl get ingress,services -o wide
```

