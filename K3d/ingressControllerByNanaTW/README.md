# Kubernetes Ingress Tutorial for Beginners

Simply explained on Kubernetes Tutorial 22 by TechWorld with Nana

> `https://www.youtube.com/watch?v=80Ew_fsV4rM`

Complete Kubernetes Ingress Tutorial, in which I explain thoroughly what Ingress and Ingress Controller is, when you need Ingress and how to configure Ingress in your cluster.

## Infra by K3d

```Shell
k3d cluster create -c infra/ingressbynana.yaml
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

