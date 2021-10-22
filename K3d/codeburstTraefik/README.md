# Creating a Local Development Kubernetes Cluster with K3D and Traefik Proxy

Also called the poor man’s Kubernetes

by Emmanuel Sys

The documentations used was:

- ```https://codeburst.io/creating-a-local-development-kubernetes-cluster-with-k3s-and-traefik-proxy-7a5033cb1c2d```

## Manifests

For K3d cluster

- ```k3d-traefiktest.yaml``` config file used to create K3d cluster

Used in App0 application on ```app0``` subdirectory:

- ```app0-configmap.yaml ``` ConfigMap configuration file
- ```app0-deployment.yaml``` Deployment configuration file
- ```app0-service.yaml   ``` Service configuration file
- ```app0-ingress.yaml   ``` Ingress configuration file

## Hands-on

Create the K3d cluster

```s
k3d cluster create --config k3d-traefiktest.yaml
```

Apply manifests for each component:

```s
kubectl apply -f ./app0/app0-configmap.yaml 

kubectl apply -f ./app0/app0-deployment.yaml 

kubectl apply -f ./app0/app0-service.yaml 

kubectl apply -f ./app0/app0-ingress.yaml 

kubectl get configmaps,pods,deployments,services,ingress -o wide
```

Try to access on browser directly this address:

> ```http://<IP from Host of K3d cluster>```

## Test subpath
