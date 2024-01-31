# Kind Cluster v0

## Sources

- [Sample Kind cluster](https://github.com/thomas-maurice/sample-kind-cluster/tree/master)
- [TraefikLabs - Quick Start](https://doc.traefik.io/traefik/getting-started/quick-start-with-kubernetes/)
- [Traefik & CRD & Let's Encrypt](https://doc.traefik.io/traefik/user-guides/crd-acme/)

## Sample Kind cluster track

### Build base environment for sample kind

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

### Untaint the master

```sh
kubectl --context kind-traefikind taint nodes --all node-role.kubernetes.io/master- || true
```

### Apply the manifests

```sh
./manifest-install.sh
```

### Installs the metrics server"

```sh
kubectl --context kind-traefikind apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

### Install stuff via Helm"

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

## Kind cluster with Traefik (TraefiKind)

### Build base environment for quick start

Create the cluster

```sh
./setup.sh

kind create cluster --config traefikind.yaml
```

Test local path provisioner space:

```sh
docker exec -it traefikind-control-plane bash

cd /data/local-path
touch test.txt

## Confirm at local-path (traefikind.data/control-plane) for 'test.txt' file existence.
```

### Untaint the master node

```sh
kubectl --context kind-traefikind taint nodes --all node-role.kubernetes.io/master- || true
```

### Apply the manifests for Traefik service

Namespace:

```sh
kubectl apply -f manifest/b000-traefik-ns.yaml
```

Traefik [Kubernetes Custom Resource](https://doc.traefik.io/traefik/reference/dynamic-configuration/kubernetes-crd/):

```sh
kubectl apply -f manifest/b010-traefik-crds.yaml
```




### Permissions and Access

- `a000-role.yaml`
- `a005-account.yaml`
- `a010-role-binding.yaml`
- `a020-traefik.yaml`
- `a025-traefik-services.yaml`

```sh
kubectl apply -f manifest/a000-role.yaml \
              -f manifest/a005-account.yaml \
              -f manifest/a010-role-binding.yaml \
              -f manifest/a020-traefik.yaml \
              -f manifest/a025-traefik-services.yaml
```

## Traefik & CRD & Let's Encrypt

### Build base environment for Traefik & CRD & Let's Encrypt

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

### Untaint the master node for pods

```sh
kubectl --context kind-traefikind taint nodes --all node-role.kubernetes.io/master- || true
```

### Install Traefik CRDs

```sh
# Install Traefik Resource Definitions:
curl https://raw.githubusercontent.com/traefik/traefik/v2.10/docs/content/reference/dynamic-configuration/kubernetes-crd-definition-v1.yml -o manifest/traefik-crd-definition-v1.yaml
kubectl apply -f manifest/traefik-crd-definition-v1.yaml

# Install RBAC for Traefik:
curl https://raw.githubusercontent.com/traefik/traefik/v2.10/docs/content/reference/dynamic-configuration/kubernetes-crd-rbac.yml -o manifest/traefik-crd-rbac.yaml
kubectl apply -f manifest/traefik-crd-rbac.yaml
```

### Traefik Service

```sh
# Get manifest with both services
curl https://raw.githubusercontent.com/traefik/traefik/v2.10/docs/content/user-guides/crd-acme/02-services.yml -o manifest/traefik-service.yaml
cp manifest/traefik-service.yaml manifest/whoami-service.yaml
# Edit both files splitting services
# At spec section add `type: ClusterIP`

# Apply service for Traefik
kubectl apply -f manifest/traefik-service.yaml
```

### Traefik Deployment

```sh
# Get manifest with both deployments
curl https://raw.githubusercontent.com/traefik/traefik/v2.10/docs/content/user-guides/crd-acme/03-deployments.yml -o manifest/traefik-deployment.yaml
cp manifest/traefik-deployment.yaml manifest/whoami-deployment.yaml
# Edit both files splitting deployment
# At spec section add `type: ClusterIP`

# Apply deployment for Traefik
kubectl apply -f manifest/traefik-service.yaml
```

### Traefik Router

```sh

```

## another way...