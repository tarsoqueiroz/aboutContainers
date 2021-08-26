# K3D: K3S HA with ETCD

Tip from Nuno Captain Corsair:

> ```https://www.youtube.com/watch?v=mqXVjAkYOrw```

## A single server with 2 agents

```
k3d cluster create myHA --agents 2 --k3s-server-arg '--cluster-init'
k3d cluster list
k3d node list
kubectl get nodes -o wide
```

## ...now HA

```
k3d node create server --replicas 2 --role server --cluster myHA
k3d cluster list
k3d node list
kubectl get nodes -o wide
kubectl get all -A
```

## Kill myHA cluster

```
k3d cluster delete myHA
```

## My tests

### A single server with 3 agents

```
k3d cluster create tqHA --agents 3 --k3s-server-arg '--cluster-init'
k3d cluster list
k3d node list
kubectl get nodes -o wide
```

### ...now HA

```
k3d node create tqHA-servce --replicas 2 --role server --cluster tqHA
k3d cluster list
k3d node list
kubectl get nodes -o wide
kubectl get all -A
```

### Kill myHA cluster

```
k3d cluster delete tqHA
```

### A 3 servers HA cluster without agents

```
k3d cluster create tqHA3 --servers 3 --agents 0 --k3s-server-arg '--cluster-init'
k3d cluster list
k3d node list
kubectl get nodes -o wide
kubectl get all -A
```

### Kill tqHA3 cluster

```
k3d cluster delete tqHA3
```

## That's all folks!!!
