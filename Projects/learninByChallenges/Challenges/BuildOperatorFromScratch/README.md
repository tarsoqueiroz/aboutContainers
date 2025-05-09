# How To Build a Kubernetes Operator From Scratch

## About

> [`https://thenewstack.io/how-to-build-a-kubernetes-operator-from-scratch/`](https://thenewstack.io/how-to-build-a-kubernetes-operator-from-scratch/)

Operators streamline workflows, reduce manual intervention and support infrastructure management, key skills for anyone working in DevOps.

- May 6th, 2025 4:00pm
- by [Joshua Masiko](https://thenewstack.io/author/joshua-masiko/)

## Prerequisites

Start by installing all the necessary tools to build and run your Kubernetes operator:

- Docker
- kubectl
- Kind
- Go
- Kubebuilder

Verify your installations

```bash￼
docker --version
kubectl version --client
kind version
go version
kubebuilder version
```

## Set Up a Cluster With Kind

```bash
# Create a Kubernetes cluster using Kind
kind create cluster --name self-healing-lab
 
# Verify the cluster is running
kubectl cluster-info
```

## Test Application

```bash
mkdir -p fragile-app

cd fragile-app

go mod init 7f000001.nip.io/fragile-app

touch main.go

touch Dockerfile
```

- [`main.go`](./fragile-app/main.go)
- [`Dockerfile`](./fragile-app/Dockerfile)

```bash
# build the docker image
docker build -t fragile-app:latest .

# run it locally
docker run -p 8910:80 --rm fragile-app:latest

# send requests to the app in another terminal
# it should crash after 5 requests
for i in {1..6}; do curl localhost:8910; echo; done
```

## Deploy to Kubernetes

- Deployment manifest [`fragile-app-deployment.yaml`]()

```bash
# load the local image into Kind
kind load docker-image fragile-app:latest --name self-headling-lab

# apply the deployment
kubectl apply -f fragile-app-deployment.yaml

# check that the pod is running
kubectl get pods

# test the app
# port forward to the pod
POD_NAME=$(kubectl get pods -l app=fragile-app -o jsonpath="{.items[0
].metadata.name}")
echo $POD_NAME
kubectl port-forward $POD_NAME 8910:80

# monitoring the app in another terminal
watch -n 1 kubectl get pods

# send requests to the app in another terminal
# it should crash after 5 requests
for i in {1..6}; do curl localhost:8910; echo; done
```
