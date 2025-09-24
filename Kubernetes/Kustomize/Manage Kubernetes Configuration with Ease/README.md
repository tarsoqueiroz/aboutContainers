# Kustomize Mastery: Manage Kubernetes Configuration with Ease

## About

> [`https://www.udemy.com/course/kustomize-mastery-manage-kubernetes-configuration-with-ease`](https://www.udemy.com/course/kustomize-mastery-manage-kubernetes-configuration-with-ease)

Everything you need to know about managing real world kubernetes configurations with Kustomize.

- [**Kustomize**: Introduction to Kustomize](https://kubectl.docs.kubernetes.io/guides/introduction/kustomize/)
- [**Github**: Udemy Course Kustomize Mastery](https://github.com/galonge/udemy-kustomize-mastery)

### In this course

...you will:

- **Understand** how Kustomize works.
- **Understand** how to use kustomize to manage kubernetes manifests for multiple environments from scratch.
- **Apply** kustomize to existing kubernetes configurations manifests.
- **Assess** and decide when to use Kustomize and when the use case isn’t suitable.
- **Understand** various ways to set up Kustomize and pros and cons of each.

## Quick start

### What is Kustomize?

O **Kustomize** é uma ferramenta nativa do Kubernetes que permite customizar configurações de aplicações sem a necessidade de templates. Ele funciona com arquivos YAML comuns, aplicando "camadas" de personalização sobre uma base. Isso significa que você pode ter um arquivo de configuração base e criar variações para diferentes ambientes (produção, staging, etc.), mantendo a clareza e a rastreabilidade das mudanças.

### Kustomize Hands-on - Get Ready

Now, let us get our hands dirty a bit and see this thing we have been talking about in action.

The goal of this section is to get you started on the benefits of kustomize with the least setup required.

So, we are NOT going to install kubectl or kustomize yet, instead, we will be using a cloud service called "Killer Koda". This provides us with a playground for kubernetes with kubectl already installed.

To get started,

- Head over to (Killer Koda) - `https://killercoda.com/playgrounds/scenario/kubernetes`  to provision a demo playground (**update - May, 2023:** killa koda now requires you to use your github account or gmail)
- Confirm kubectl and kustomize is installed and versions with the following command: 

```sh
kubectl version --short
```

The output should look something like the following:

```sh
Client Version: v1.25.2
Kustomize Version: v4.5.7
```

As long as you have a kubectl client version higher than v1.14, you should have kustomize and be ready to proceed.

### Kind for Local Kubernetes cluster

```sh
kind create cluster --config ./manifests/k8scluster.yaml -n k8stomize

kind get clusters 

kubectl get nodes -o wide
```

### Hands-on Live

#### Deploy WordPress with tradicional manifests

```sh
kubectl apply -f manifests/wordpress-hol/example.v1/

kubectl get pods -o wide

kubectl get svc -o wide

kubectl port-forward svc/wordpress --address 0.0.0.0 8888:80
```

Browse to `http://localhost:8888` and you'll see the WordPress app.

Clean-up the instalation.

```sh
kubectl delete -f manifests/wordpress-hol/example.v1/

kubectl get pods
```

#### Deploy WordPress with base manifests

```sh
kubectl create ns wordpress-v1

kubectl apply -k manifests/wordpress-hol/kustomize/base/ -n wordpress-v1

kubectl get pod -A

kubectl get pod -n wordpress-v1

kubectl describe pod wordpress-7bfbd4c494-ztzjk -n wordpress-v1

kubectl kustomize manifests/wordpress-hol/kustomize/base/

kubectl kustomize manifests/wordpress-hol/kustomize/v2/

kubectl apply -k manifests/wordpress-hol/kustomize/v2/ -n wordpress-v2

kubectl get pod -A

kubectl get pod -n wordpress-v2

kubectl get svc -n wordpress-v2

kubectl port-forward svc/wordpress -n wordpress-v2 8888:80

kubectl kustomize manifests/wordpress-hol/kustomize/v3/

kubectl create ns wordpress-v3

kubectl apply -k manifests/wordpress-hol/kustomize/v3/ -n wordpress-v3

kubectl get pods -n wordpress-v3

kubectl get svc -n wordpress-v3
```

Browse to `http://localhost:8910` and you'll see the WordPress app.

Let's go to configure DB connection:

- **Database Name**: `wordpress`
- **Username**: `root`
- **Password**: `password`
- **Database Host**: `10.96.198.92` (*from svc of last command*)
- **Table Prefix**: `wp_`

```sh
kubectl port-forward svc/wordpress -n wordpress-v3 --address 0.0.0.0 8910:80

kubectl delete ns wordpress-v1

kubectl delete ns wordpress-v2

kubectl delete ns wordpress-v3
```

## That's

...all folks!!!
