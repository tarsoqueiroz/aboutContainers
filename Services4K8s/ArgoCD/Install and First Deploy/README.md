# How to Install ArgoCD on Minikube and Deploy an App

## About

- [How to Install ArgoCD on Minikube and Deploy an App](https://www.fosstechnix.com/how-to-install-argocd-on-minikube/)
- [Youtube: How to Install ArgoCD on Minikube and Deploy an App](https://www.youtube.com/watch?v=Vpe3oUgoyq4)

In this class on we are going to cover:

- How to Install Minikube on Ubuntu 22.04 LTS
- How to Install ArgoCD on Minikube
- Deploy an App on ArgoCD

## Cluster K8s (KinD)

```sh
# Local storage
./setup.sh
# Create cluster
kind create cluster --config ClusterConf.yaml
# Verifying
kubectl cluster-info --context kind-kluster
kubectl get nodes -o wide
docker container exec -it kluster-control-plane sh
# inside container
ls -lah /data
```

## Install ArgoCD

```sh
# Create NS
kubectl create ns argocd
ku get ns
# Apply ArgoCD manifest
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.5.8/manifests/install.yaml
# Verifying
kubectl get all -n argocd
```

## Access ArgoCD UI on Browser

```sh
# On other shell
kubectl port-forward svc/argocd-server -n argocd --address 0.0.0.0 8081:443
# Get the initial password for the admin user
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

## Deploying an app

Actions:

- `+ New App`
  - `GENERAL`
    - App name: `guestbook`
    - Project name: `default`
    - Sync policy: `Manual`
  - `SOURCE`
    - Repository: `https://github.com/argoproj/argocd-example-apps.git`
    - Revision: `HEAD`
    - Path: `guestbook`
  - `DESTINATION`
    - Cluster URL: `https://kubernetes.default.svc`
    - Namespace: `default`
  - `CREATE`
- Click on `guestbook`
  - `SYNC`
  - `SYNCHRONIZE`

Now we can App got deployed on ArgoCD.

## TODO

- Ingress on cluster
- Ingress for ArgoCD
- Ingress for app
