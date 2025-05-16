# What are Custom Resource Definitions (CRDs) in Kubernetes - CRDs and Operators

## About

By [CookNCode](https://www.youtube.com/@cookncode)

In this hands-on tutorial series, we will dive deep into CRDs and Operators, two powerful concepts that empower you to extend Kubernetes with custom resources and automated workflows.

Resources:

- [Custom Resource Definitions](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/)
- [OperatorHub.io](https://operatorhub.io/)
- Github Repo: [Operator framework - awesome operators](https://github.com/operator-framework/awesome-operators)

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

## Part 1 - [Understanding CRDs](https://www.youtube.com/watch?v=TScDYMym7LA)

In this first episode, we'll understand what Custom Resource Definitions (CRDs) are and how they enable you to create your own resource types, tailored to your specific use cases.
CRDs are a vital aspect of Kubernetes' extensibility, allowing you to define new objects and their behaviors, just like native Kubernetes resources.

Resources:

- Github Repo: [multi-node-kind-cluster/crds_and_operators](https://github.com/shabbirsaifee92/multi-node-kind-cluster)
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

## cleaning up
kubectl delete -f ./crd-instance.yaml 
kubectl get tlscertificates.tarsoqueiroz.io -A

kubectl delete -f ./crd.yaml 
kubectl get crds
```

## Part2 - [Kubernetes CRDs & Operators: Writing Your First Operator](https://www.youtube.com/watch?v=5HJbyLppeZY)

In this video, we dive into Kubernetes Operators - what they are, how they work, and how to write one using Shell Operator. We cover:

- How Kubernetes controllers work
- What are operators
- Popular operators in the wild
- Writing an operator using Shell Operator
- Running and testing our operator

Resources:

- Github Repo: [k8s-crds-operator](https://github.com/shabbirsaifee92/k8s-crds-operator)
- [Shell Operator Documentation](https://github.com/flant/shell-operator)
- [Operator SDK Documentation](https://sdk.operatorframework.io/)
- [Kubernetes Operator Documentation](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/)

```bash
## build the docker image
docker build -t tarsoqueiroz/email-notifier-operator:1.0.0 .
docker image ls tarsoqueiroz/*

## load the local image into Kind
kind load docker-image tarsoqueiroz/email-notifier-operator:1.0.0 --name k8s-crd

## deploying the app
kubectl apply -f 01-namespace.yaml 
kubectl apply -f 02-rbac.yaml 
kubectl apply -f 03-pod.yaml

## inspecting the log's pod
kubectl logs -n email-notifier-operator pods/email-notifier-operator 
kubectl logs -n email-notifier-operator pods/email-notifier-operator  | grep -ie "Logic triggered"

## installing the operator
kubectl apply -f notifier-crd.yaml 
kubectl apply -f notifier-instance.yaml 

## inspecting the log's pod
kubectl logs -n email-notifier-operator pods/email-notifier-operator 
kubectl logs -n email-notifier-operator pods/email-notifier-operator  | grep -ie "Logic triggered"

## removing the notifier instance
kubectl delete -f ./notifier-instance.yaml 

## inspecting the log's pod
kubectl logs -n email-notifier-operator pods/email-notifier-operator  | grep -ie "Logic triggered"

## reinstalling the notifier instance
kubectl apply -f ./notifier-instance.yaml 

## inspecting the log's pod
kubectl logs -n email-notifier-operator pods/email-notifier-operator  | grep -ie "Logic triggered"

## cleaning up
kubectl delete -f ./03-pod.yaml 
kubectl delete -f ./02-rbac.yaml 
kubectl delete -f ./01-namespace.yaml 
kubectl delete -f ./notifier-instance.yaml 
kubectl delete -f ./notifier-crd.yaml 
```
