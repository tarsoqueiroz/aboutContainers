# Kind Cluster Tarso.v0

## Sources

- [Sample Kind cluster](https://github.com/thomas-maurice/sample-kind-cluster/tree/master)
- [TraefikLabs - Quick Start](https://doc.traefik.io/traefik/getting-started/quick-start-with-kubernetes/)
- [Traefik & CRD & Let's Encrypt](https://doc.traefik.io/traefik/user-guides/crd-acme/)
- [Metrics-Server in Kubernetes](https://medium.com/google-cloud/metrics-server-in-kubernetes-d190410a8e30)
- [metrics-server](https://artifacthub.io/packages/helm/metrics-server/metrics-server)

## Kind cluster with Traefik as Ingress

Create the cluster:

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

Pre-config:

```sh
# Admin account
kubectl --context kind-traefikind apply -f manifest/t000/cluster-02-account.yaml
```

Install metrics components:

```sh
# INSTALL
# by helm
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update
helm install metrics-server metrics-server/metrics-server

# INSTALL
# by manifest
kubectl --context kind-traefikind apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl --context kind-traefikind apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.7.0/components.yaml
# or
kubectl --context kind-traefikind apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.7.0/high-availability-1.21+.yaml

# CORRECTIONS
kubectl edit deployment metrics-server
kubectl --context kind-traefikind get deployments -A
# Put the follow flag “- --kubelet-insecure-tls=true” under the args section of the deployment
kubectl --context kind-traefikind get deployments -A

# VERIFY
ku top nodes
ku top pods -A
```

Install Prometheus:

```sh
kubectl --context kind-traefikind apply -f manifest/t000/metrics-00-ns.yaml 
kubectl --context kind-traefikind get ns
# ADD REPO PROMETHEUS
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
# UPDATE HELM REPO
helm repo update
helm install prometheus -n monitoring prometheus-community/kube-prometheus-stack
watch -n 1 kubectl --namespace monitoring get pods -l "release=prometheus" -o wide
```

Install Kubernetes Dashboard:

```sh
kubectl --context kind-traefikind apply -f manifest/t000/dashboard-00-ns.yaml
kubectl --context kind-traefikind get ns
kubectl --context kind-traefikind apply -f manifest/t000/dashboard-02-account.yaml
# ADD REPO DASHBOARD
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
# Updating helm repo
helm repo update
# Install dashboard
helm install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard \
    --namespace kubernetes-dashboard \
    --set protocolHttp=true \
    --set serviceAccount.create=false \
    --set serviceAccount.name=admin-user \
    --set metricsScraper.enabled=true
# Testing
export POD_NAME=$(kubectl get pods -n kubernetes-dashboard -l "app.kubernetes.io/name=kubernetes-dashboard,app.kubernetes.io/instance=kubernetes-dashboard" -o jsonpath="{.items[0].metadata.name}")
echo http://127.0.0.1:9090/
kubectl -n kubernetes-dashboard port-forward $POD_NAME 9090:9090
```

Install Traefik:

```sh
# followin ./manifest-install.sh

# Untaint the master
kubectl --context kind-traefikind taint nodes --all node-role.kubernetes.io/master- || true
kubectl --context kind-traefikind taint nodes --all node-role.kubernetes.io/control-plane- || true
# CREATE NAMESPACE
kubectl --context kind-traefikind apply -f manifest/t000/traefik-00-ns.yaml
# CREATE ADMIN ACCOUNT
kubectl --context kind-traefikind apply -f manifest/t000/traefik-02-account.yaml
# INSTALL TRAEFIK CUSTOM RESOURCE DEFINITIONS
kubectl --context kind-traefikind apply -f https://raw.githubusercontent.com/traefik/traefik/v2.10/docs/content/reference/dynamic-configuration/kubernetes-crd-definition-v1.yml
# INSTALL TRAEFIK RBAC
kubectl --context kind-traefikind apply -f https://raw.githubusercontent.com/traefik/traefik/v2.10/docs/content/reference/dynamic-configuration/kubernetes-crd-rbac.yml
# CREATE SERVICE
kubectl --context kind-traefikind apply -f manifest/t000/traefik-05-service.yaml
# CREATE DEPLOYMENT
kubectl --context kind-traefikind apply -f manifest/t000/traefik-07-deployment.yaml
# CREATE INGRESS
kubectl --context kind-traefikind apply -f manifest/t000/traefik-09-ingress.yaml



```

### Install stuff via Helm"


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
kubectl apply -f manifest/traefik-deployment.yaml
```

### Traefik Router

```sh
# Get router manifest
curl https://raw.githubusercontent.com/traefik/traefik/v2.10/docs/content/user-guides/crd-acme/04-ingressroutes.yml -o manifest/traefik-04-ingressroutes.yaml
cp manifest/traefik-deployment.yaml manifest/whoami-deployment.yaml
# Edit both files splitting deployment
# At spec section add `type: ClusterIP`

# Apply deployment for Traefik
kubectl apply -f manifest/traefik-deployment.yaml

https://raw.githubusercontent.com/traefik/traefik/v2.10/docs/content/user-guides/crd-acme/04-ingressroutes.yml
```

## another way...