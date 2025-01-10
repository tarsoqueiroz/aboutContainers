# Understanding Kubernetes Volume Types

## About

> [`https://kubefeeds.com/understanding-kubernetes-volume-types-emptydir-configmap-secret-hostpath/`](https://kubefeeds.com/understanding-kubernetes-volume-types-emptydir-configmap-secret-hostpath/)

Kubernetes volumes provide a way for containers running in Pods to access and share data. Each volume type in Kubernetes serves a specific purpose, enabling different use cases such as temporary storage, configuration management, secret handling, or mounting host directories.

This article explores key Kubernetes volume types: EmptyDir, ConfigMap, Secret, and HostPath.

## EmptyDir Volume

- [`emptydir.yaml`](emptydir.yaml)

```sh
kubectl apply -f ./emptydir.yaml

kubectl exec --stdin --tty pods/emptydir-pod -- /bin/sh

/ # ls -alhF /data

/ # cat /data/hello.txt 

/ # exit
```

## ConfigMap Volume

```sh
kubectl create configmap app-config-imperative --from-literal=app.name.imperative=Imperative
kubectl describe configmaps app-config-imperative 
kubectl get configmaps app-config-imperative -o yaml

kubectl apply -f ./configmap-declarative.yaml 
kubectl describe configmaps app-config-declarative 
kubectl get configmaps app-config-declarative -o yaml

kubectl get configmaps 
```

- [`configmap.yaml`](configmap.yaml)

```sh
kubectl apply -f ./configmap.yaml 

kubectl exec --stdin --tty pods/configmap-pod -- /bin/sh

/ # ls -alhF

/ # ls -alhF /config

/ # ls -alhF /config/imperative/

/ # cat /config/imperative/app.name.imperative 

/ # ls -alhF /config/declarative/

/ # cat /config/declarative/app.name.declarative 

/ # exit
```

## Secret Volume

```sh
kubectl create secret generic app-secret-imperative --from-literal=secret-imperative=1234567890abcdef
kubectl describe secrets app-secret-imperative
kubectl get secrets app-secret-imperative -o yaml

kubectl apply -f ./secret-declarative.yaml 
kubectl describe secrets app-secret-declarative
kubectl get secrets app-secret-declarative -o yaml

kubectl get secrets
```

- [`secret.yaml`](secret.yaml)

```sh
kubectl apply -f ./secret.yaml 

kubectl exec --stdin --tty pods/secret-pod -- /bin/sh

/ # ls -alhF

/ # ls -alhF /secrets

/ # ls -alhF /secrets/imperative/

/ # cat /secrets/imperative/secret-imperative

/ # ls -alhF /secrets/declarative/

/ # cat /secrets/declarative/secret-declarative 

/ # exit
```

## HostPath Volume

- [`hostpath.yaml`](hostpath.yaml)

```sh
kubectl apply -f ./hostpath.yaml 

docker exec -it { traefik-control-plane | traefik-worker | traefik-worker2 | traefik-worker3 }

/ # ls -alhF

/ # ls -alhF /data

/ # cat /data/nameofhost.txt
```

## PV/PVC Volume

- [`pvworker1.yaml`](./pvworker1.yaml)
- [`pvcworker1.yaml`](./pvcworker1.yaml)
- [`pvpvc1.yaml`](./pvpvc1.yaml)
- [`pvworker2.yaml`](./pvworker2.yaml)
- [`pvcworker2.yaml`](./pvcworker2.yaml)
- [`pvpvc2.yaml`](./pvpvc2.yaml)
- [`pvworker3.yaml`](./pvworker3.yaml)
- [`pvcworker3.yaml`](./pvcworker3.yaml)
- [`pvpvc3.yaml`](./pvpvc3.yaml)

```sh
# Terminal control plane
docker exec -ti traefik-control-plane sh
# Worker 1 terminal worker
docker exec -it traefik-worker sh
# Worker 2 terminal worker
docker exec -it traefik-worker2 sh
# Worker 3 terminal worker
docker exec -it traefik-worker3 sh

# Main terminal
kubectl apply -f pvworker3.yaml 
kubectl get pv -o wide
kubectl get pv pvw3 -o wide

kubectl apply -f pvcworker3.yaml 
kubectl get pv,pvc -o wide

kubectl apply -f pvpvc3.yaml 
kubectl get pods -o wide

kkubectl exec --stdin --tty pods/task-pv3-pod -- /bin/sh

kubectl apply -f pvworker2.yaml 
kubectl apply -f pvcworker2.yaml 
kubectl get pv,pvc -o wide

kubectl apply -f pvpvc2.yaml 

kubectl get pod,pv,pvc -o wide

kubectl apply -f pvcworker1.yaml 
kubectl get pv,pvc -o wide

kubectl apply -f pvpvc1.yaml 

kubectl get pod,pv,pvc -o wide

kubectl get  pod -o wide

kubectl delete -f configmap.yaml 
kubectl delete -f emptydir.yaml -f hostpath.yaml -f secret.yaml 
kubectl get pod
kubectl get pod -o wide
kubectl delete -f pvpvc1.yaml -f pvpvc2.yaml -f pvpvc3.yaml 
kubectl apply -f pvpvc1.yaml -f pvpvc2.yaml -f pvpvc3.yaml 
kubectl get pod -o wide
```
