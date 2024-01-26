# Kind tests

## Create cluster

```sh
kind create cluster --config cluster.yaml
```

## Tool box

```sh
kubectl apply -f toolbox-pod.yaml

kubectl exec -it toolbox -- /bin/sh
```
