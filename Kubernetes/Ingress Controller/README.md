# Ingress Controller on Kubernetes

## [NGINX Basic Configuration](https://docs.nginx.com/nginx-ingress-controller/configuration/ingress-resources/basic-configuration/)

```sh
# Cluster K8s creation
kind create cluster --config 00-cluster.yaml

# Deploy NGINX ingress controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Wait until is ready
kubectl wait --namespace ingress-nginx   --for=condition=ready pod   --selector=app.kubernetes.io/component=controller   --timeout=90s

# Up and run a sample
ku apply -f 01-secret.yaml -f 02-deploy.yaml -f 03-service.yaml -f 04-ingress.yaml 

# Check for objects
ku get pod,deployment,service,ingress -o wide
```
