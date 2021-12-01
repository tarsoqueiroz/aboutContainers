# Criando um cluster K8S com NGINX Contoller em sua Máquina

> `https://www.youtube.com/watch?v=1lx91nhzNe0`

## KinD install

KinD site: `https://kind.sigs.k8s.io/`

Test install and completion for bash:

```Shell
kind version

kind completion bash > kind_completion
less kind_completion 
sudo mv kind_completion /etc/bash_completion.d/.
sudo chown root:root /etc/bash_completion.d/kind_completion 
ll /etc/bash_completion.d/
source ~/.bashrc 
```

## First usage

```Shell
kind get clusters
kind create cluster --name giropops-01
kind get clusters
kubectl get nodes 
```

## Configuration file

- `kind-cluster.yaml` file

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
```

```Shell
kind create cluster --name giropops-02 --config kind-cluster.yaml
kubectl get nodes
kind get clusters 
kubectl config get-contexts 
kubectl cluster-info --context kind-giropops-02
kubectl config get-contexts 
kubectl config use-context kind-giropops-01
kubectl get nodes
```

- `kind-clusterb.yaml` file

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: giropops-02b
nodes:
- role: control-plane
- role: worker
- role: worker
```

```Shell
kind create cluster --config kind-clusterb.yaml
kubectl get nodes
kind get clusters 
kubectl config get-contexts 
kubectl cluster-info --context kind-giropops-02
kubectl config get-contexts 
```

## Deleting clusters

```Shell
kind delete cluster --name giropops-01
kind delete cluster --name giropops-02 
kind delete cluster --name giropops-02b
kind get clusters
```

## HA cluster with Ingress controller

- `kind-ingress.yaml` file

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: giropops-ingress
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
- role: worker
```

```Shell
kind create cluster --config ./kind-ingress.yaml
watch -n 1 kubectl get nodes
kind get clusters 
kubectl config get-contexts 
```

## LINUXtips Ingress tests

- `testing-ingress.yaml` file

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: giropops-deploy
spec:
  selector:
    matchLabels:
      app: giropops
  template:
    metadata:
      labels:
        app: giropops
    spec:
      containers:
      - name: giropops
        image: hashicorp/http-echo:0.2.3
        args:
        - "-text=GiroPops"
        resources:
          limits:
            memory: "128Mi"
            cpu: "500m"
        ports:
        - containerPort: 5678
---
apiVersion: v1
kind: Service
metadata:
  name: giropops-service
spec:
  selector:
    app: giropops
  # type: LoadBalancer
  ports:
  - port: 5678
    targetPort: 5678
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: strigus-deploy
spec:
  selector:
    matchLabels:
      app: strigus
  template:
    metadata:
      labels:
        app: strigus
    spec:
      containers:
      - name: strigus
        image: hashicorp/http-echo:0.2.3
        args:
        - "-text=Strigus"
        resources:
          limits:
            memory: "128Mi"
            cpu: "500m"
        ports:
        - containerPort: 5678
---
apiVersion: v1
kind: Service
metadata:
  name: strigus-service
spec:
  selector:
    app: strigus
  # type: LoadBalancer
  ports:
  - port: 5678
    targetPort: 5678
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: girostrigus-ingress
  labels:
    name: girostrigus
spec:
  rules:
  # - host: <Host>
  - http:
      paths:
      - pathType: Prefix
        path: "/giropops"
        backend:
          service:
            name: giropops-service
            port: 
              number: 5678
      - pathType: Prefix
        path: "/strigus"
        backend:
          service:
            name: strigus-service
            port: 
              number: 5678
```

```Shell
kubectl apply -f testing-ingress.yaml 
kubectl get pods -o wide
kubectl get services -o wide
kubectl get ingress -o wide
kubectl describe ingress girostrigus-ingress
curl localhost
curl localhost/giropops
curl localhost/strigus
```


## LINUXtips Ingress tests

- `kind-sample.yaml` file

```yaml
kind: Pod
apiVersion: v1
metadata:
  name: foo-app
  labels:
    app: foo
spec:
  containers:
  - name: foo-app
    image: hashicorp/http-echo:0.2.3
    args:
    - "-text=foo"
    resources:
      limits:
        memory: "128Mi"
        cpu: "500m"
---
kind: Service
apiVersion: v1
metadata:
  name: foo-service
spec:
  selector:
    app: foo
  ports:
  # Default port used by the image
  - port: 5678
---
kind: Pod
apiVersion: v1
metadata:
  name: bar-app
  labels:
    app: bar
spec:
  containers:
  - name: bar-app
    image: hashicorp/http-echo:0.2.3
    args:
    - "-text=bar"
    resources:
      limits:
        memory: "128Mi"
        cpu: "500m"
---
kind: Service
apiVersion: v1
metadata:
  name: bar-service
spec:
  selector:
    app: bar
  ports:
  # Default port used by the image
  - port: 5678
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
spec:
  rules:
  - http:
      paths:
      - pathType: Prefix
        path: "/foo"
        backend:
          service:
            name: foo-service
            port:
              number: 5678
      - pathType: Prefix
        path: "/bar"
        backend:
          service:
            name: bar-service
            port:
              number: 5678
---
```

```Shell
kubectl apply -f kind-sample.yaml 
kubectl get pods -o wide
kubectl get services -o wide
kubectl get ingress -o wide
kubectl describe ingress example-ingress
curl localhost
curl localhost/foo
curl localhost/bar
```

