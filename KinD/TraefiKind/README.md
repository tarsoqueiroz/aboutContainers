# Traefik with Kind

## References of References

- `https://github.com/rchidana/k8s-traefik/blob/master/hello-ingress.yaml`
- `https://doc.traefik.io/traefik/getting-started/quick-start-with-kubernetes/`
- `https://doc.traefik.io/traefik/v1.7/user-guide/kubernetes/`

Links:

- [Kubernetes Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [Kubernetes Service](https://kubernetes.io/docs/concepts/services-networking/service/)
- [Install Traefik](https://doc.traefik.io/traefik/getting-started/install-traefik/)
- [Traefik & Kubernetes](https://doc.traefik.io/traefik/providers/kubernetes-ingress/)

Github:

- `https://github.com/rchidana/k8s-traefik`

## 26 Brains

### References

- [Reference Video](https://www.youtube.com/watch?v=-YwOG515M9M)

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

```sh
kind create cluster --config tk-cluster.yaml
```

### Traefik install

```sh
kubectl create namespace traefik

helm install traefik traefik/traefik -n traefik --create-namespace -f tk-traefik-values.yaml

kubectl get pods,deployment,services,ingress -A -o wide
```

### Test connection

```sh
kubectl apply -f tk-deployment.yaml

kubectl get pods,deployment,services,ingress -A -o wide

kubectl apply -f tk-ingress.yaml

kubectl get pods,deployment,services,ingress -A -o wide
```

Try to access the following links:

- `http://0a0f122c.nip.io:9000/dashboard/`
- `http://0a0f122c.nip.io:8080/`
- `http://0a0f122c.nip.io:9100/metrics/`
- `http://whoami.0a0f122c.nip.io:8080/`
- `http://whoami.0a0f122c.nip.io:9100/metrics`

### Installing a kubernetes dashboard

- `https://medium.com/@munza/local-kubernetes-with-kind-helm-dashboard-41152e4b3b3d`

To access Dashboard run:
  kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-nginx-controller 8443:443

NOTE: In case port-forward command does not work, make sure that nginx service name is correct.
      Check the services in Kubernetes Dashboard namespace using:
        kubectl -n kubernetes-dashboard get svc

Dashboard will be available at:
  https://localhost:8443



### Remove cluster

```sh
kind delete cluster --name tkluster
```

## Others test

### Source

- [Deploy K8ssandra and Traefik with Kind](https://docs.k8ssandra.io/tasks/connect/ingress/kind-deployment/)
- [Traefik (Ingress) Kubernetes Setup](https://www.youtube.com/watch?v=KRl5wpbi60Y)
- [Kubernetes Traefik Ingress](https://mpolinowski.github.io/docs/DevOps/Kubernetes/2019-02-01--kubernetes-traefik-ingress/2019-02-01/)
- [Using traefik for ingress on a kind cluster](https://blue42.net/devops/2021/k8s-kind-traefik/)

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
