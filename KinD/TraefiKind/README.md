# Traefik with Kind

## 26 Brains

### References

- [Reference Video](https://www.youtube.com/watch?v=-YwOG515M9M)

Links

- [Kubernetes Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [Kubernetes Service](https://kubernetes.io/docs/concepts/services-networking/service/)
- [Install Traefik](https://doc.traefik.io/traefik/getting-started/install-traefik/)
- [Traefik & Kubernetes](https://doc.traefik.io/traefik/providers/kubernetes-ingress/)

### Create cluster

`sh
kind create cluster --config 26brain-cluster.yaml
`

### Apply deployment

```sh
kubectl apply -f 26brain-deployment.yaml

kubectl get pods -o wide
kubectl get pods,svc -o wide
```

### Try to access

```sh
kubectl port-forward services/nginx-service 40000:80
kubectl port-forward --address=0.0.0.0 services/nginx-service 40000:80
```

Go to browser and try to access: `http://0a0f122c.nip.io:40000/`

### Traefik install

```sh
helm install traefik traefik/traefik

kubectl get pods,services -o wide
```

### Inspecting Traefik pod

```sh
kubectl describe pod <traefik-ID>

## This command on other terminal (t 1)
kubectl port-forward --address 0.0.0.0 pod/traefik-5db9f656c-zxwxz 9001:9000
```

Go to browser and try to access: `http://0a0f122c.nip.io:9001/dashboard/#/`

### Sharing deployment by trafik

```sh
## This command on other terminal (t 2)
kubectl port-forward --address 0.0.0.0 pod/traefik-5db9f656c-zxwxz 8001:8000
```

Go to browser and try to access:

- `http://0a0f122c.nip.io:8001/`
- `http://0a0f122c.nip.io:8001/nginx-test`

```sh
kubectl apply -f 26brain-ingress.yaml

kubectl apply -f 26brain-ingress-path.yaml
```

Go to browser and try to access:

- `http://0a0f122c.nip.io:8001/`
- `http://0a0f122c.nip.io:8001/nginx-test`

## Traefik in Kind by TQ

### Create cluster

`sh
kind create cluster --config 26brain-cluster.yaml
`

### Traefik install

```sh
helm install traefik traefik/traefik -n traefik --create-namespace -f tk-traefik-values.yaml

kubectl get pods,services -o wide
```


## Old test

### Source

- [Deploy K8ssandra and Traefik with Kind](https://docs.k8ssandra.io/tasks/connect/ingress/kind-deployment/)
- [Traefik (Ingress) Kubernetes Setup](https://www.youtube.com/watch?v=KRl5wpbi60Y)

### Create cluster

```sh
kind create cluster --config traefikind-cluster.yaml
```

### Apply Traefik

```sh
helm repo add traefik https://helm.traefik.io/traefik
helm repo update
helm install traefik traefik/traefik -n traefik --create-namespace -f traefikind-values.yaml
```

### Try

```sh
http://0a0f122c.nip.io:9000/dashboard/
```

## That's all
