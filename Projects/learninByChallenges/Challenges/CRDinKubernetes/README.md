# What are Custom Resource Definitions (CRDs) in Kubernetes - CRDs and Operators

## About

By [CookNCode](https://www.youtube.com/@cookncode)

In this hands-on tutorial series, we will dive deep into CRDs and Operators, two powerful concepts that empower you to extend Kubernetes with custom resources and automated workflows.

## Preparing the Environment

```bash
## creating Kind cluster
kind create cluster --config ./k8s-crd.yaml --name k8s-crd

## installing Calico
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/custom-resources.yaml

## installing Nginx Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

## labeling work node
kubectl label node k8s-crd-worker ingress-ready=true
```

## Part 1: [Understanding CRDs](https://www.youtube.com/watch?v=TScDYMym7LA)

In this first episode, we'll understand what Custom Resource Definitions (CRDs) are and how they enable you to create your own resource types, tailored to your specific use cases.
CRDs are a vital aspect of Kubernetes' extensibility, allowing you to define new objects and their behaviors, just like native Kubernetes resources.

- CRD definition: [`crd.yaml`](./crd.yaml)
- CRD instance: [`crd-instance.yaml`](./crd-instance.yaml)

```bash
## creating CRD
kubectl apply -f ./crd.yaml 

kubectl get crds

## creating CRD instance
kubectl apply -f ./crd-instance.yaml

## inspecting CRD instance
kubectl get tlscertificate
kubectl get tlscertificates

kubectl get tlscertificate.tarsoqueiroz.io
kubectl get tlscertificates.tarsoqueiroz.io

kubectl get tls
kubectl get tls -A

kubectl describe tlscertificate
kubectl describe tlscertificates

kubectl describe tlscertificate.tarsoqueiroz.io example-tls-cert
kubectl describe tlscertificates.tarsoqueiroz.io example-tls-cert
```
