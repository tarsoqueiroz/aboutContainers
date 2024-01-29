# Kind Cluster v0

## Build base environment

Create the cluster

```sh
./setup.sh

kind create cluster --config traefikind.yaml
```

Test local path provisioner:

```sh
docker exec -it traefikind-control-plane bash

cd /data/local-path
touch test.txt

## Confirm at local-path (traefikind.data/control-plane) for 'test.txt' file existence.
```

## Untaint the master

```sh
kubectl --context kind-traefikind taint nodes --all node-role.kubernetes.io/master- || true
```

## Apply the manifests

```sh
./manifest-install.sh
```

## Installs the metrics server"

```sh
kubectl --context kind-traefikind apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

## Install stuff via Helm"

Adding repo dashboard:

```sh
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
```

Adding repo prometheus:

```sh
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
```

Updating repo info:

```sh
helm repo update
```

Install dashboard:

```sh
helm install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard \
    --namespace kubernetes-dashboard \
    --set protocolHttp=true \
    --set serviceAccount.create=false \
    --set serviceAccount.name=admin-user \
    --set metricsScraper.enabled=true
```


