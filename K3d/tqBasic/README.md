# tq Basic cluster for K3d

Sample configs for fast up K3d cluster environment

## Cluster up

```s
k3d cluster create --config ./k3d-tqK3d.yaml
k3d cluster list
k3d node list
kubectl get nodes -o wide
```