# Basic about K3d from Tarso

## Starting a cluster config file

> `k3d config`

```sh
# Create a sample config file
k3d config init # Default k3d-default.yaml file
k3d config init -o newcluster.yaml

# Migrate from old config file version
k3d config migrate <oldVersion.yaml> <newVersion.yaml>
```

## Sample config file for start

> [`sample.yaml`](./sample.yaml)

```yaml
---
apiVersion: k3d.io/v1alpha4
kind: Simple
metadata:
  name: sample # Name of this K8s cluster

# Qty of nodes by role
servers: 1
agents: 3

kubeAPI:
  hostIP: 0.0.0.0
  hostPort: "6443"

# Images tags from https://hub.docker.com/r/rancher/k3s/tags
image: docker.io/rancher/k3s:v1.26.0-k3s2
# image: docker.io/rancher/k3s:v1.25.5-k3s2
# image: docker.io/rancher/k3s:v1.24.9-k3s2

volumes:
- nodeFilters:
  - all
  # volume: {/node/path}:{/local/storage/path}
  volume: /tmp:/tmp

ports:
- nodeFilters:
  - loadbalancer
  port: 10080:80
- nodeFilters:
  - loadbalancer
  port: 10443:443
- nodeFilters:
  - loadbalancer
  port: 18080:8080
- nodeFilters:
  - loadbalancer
  port: 18843:8443

env:
- envVar: cluster=sample
  nodeFilters:
  - all

options:
  k3d:
    wait: true
    timeout: 360000000000
    disableLoadbalancer: false
    disableImageVolume: false
    disableRollback: false
    loadbalancer: {}

  k3s:
    extraArgs:
    - arg: --tls-san=127.0.0.1
      nodeFilters:
      - server:*

  kubeconfig:
    updateDefaultKubeconfig: true
    switchCurrentContext: true
  runtime:
    HostPidMode: false

registries: {}
```

## Starting cluster

```sh
# Creating K8s cluster
k3d cluster create -c ./sample.yaml

# Simple checks
kubectl cluster-info 
kubectl get nodes -o wide
kubectl get -A -o wide
```
