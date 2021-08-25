# K3D: Rodando Kubernetes localmente com Docker

> ```https://www.youtube.com/watch?v=q1811odFfKM```

## Creating the cluster

```
k3d cluster create -p "8000:30000@loadbalancer" --agents 2
```

## Verifing the cluster created

```
kubectl config use-context k3d-k3s-default
kubectl cluster-info
kubectl get nodes
docker container ls -a
```

## First deployment

- ```deployment.yaml``` file

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
```

- Aplying the deployment

```
kubectl apply -f deployment.yaml 
kubectl get pods
kubectl get pod
kubectl get deployment
```

## Adding service

- ```service.yaml``` file

```
apiVersion: v1
kind: Service
metadata:
  name: nginx
spec:
  selector:
    app: nginx
  type: LoadBalancer
  ports:
  - port: 8000
    targetPort: 80
    nodePort: 30000
```

- Aplying the service

```
kubectl apply -f service.yaml 
kubectl get services
```

## Trying to access the service

```
curl localhost:8000
```

## Deleting the cluster

```
k3d cluster delete
docker container ls -a
```

## That's all folk!!!
