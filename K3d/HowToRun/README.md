# K3d - How to run Kubernetes cluster locally using Rancher k3s

Tip from DevOps Toolkit by Viktor Farcic:

> ```https://www.youtube.com/watch?v=mCesuGk-Fks```

GitHub source:

> ```https://github.com/vfarcic/k3d-demo```

## A cluster from a file configuration

```
k3d cluster create --config ./viktorFarcic-k3d.yaml
k3d cluster list
k3d node list
kubectl get nodes -o wide
```

## Sample app deployment

```
kubectl apply --filename ./k8s/
kubectl get pods,deployments,services,ingress
```

## After delete the cluster, that's all folks!!!
