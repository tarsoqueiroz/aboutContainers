# Kind Cluster version 1.23.6

## About

This steps aims at showcasing how to create a basic viable Kind cluster (kubernetes version 1.23.6) with a dynamic volumes provisioner as well as a pre-configured traefik v2 ingress controller.

References:

- [Sample Kind cluster](https://github.com/thomas-maurice/sample-kind-cluster)
- [Unseal vault](https://github.com/thomas-maurice/unseal-vault)

## Setup cluster

Commands:

```sh
# Create the cluster
kind create cluster --config ./cluster.yaml

# Untaint the master
kubectl --context kind-tmaurice describe nodes tmaurice-control-plane
kubectl --context kind-tmaurice taint nodes --all node-role.kubernetes.io/master- || true

# Applies the manifests

#  00-namespaces.yaml
kubectl --context kind-tmaurice apply -f ./00-namespaces.yaml

# 00-traefik-crds.yaml
kubectl --context kind-tmaurice apply -f ./00-traefik-crds.yaml

# 02-traefik-rbac.yaml
kubectl --context kind-tmaurice apply -f ./02-traefik-rbac.yaml

# 03-traefik-svc.yaml
kubectl --context kind-tmaurice apply -f ./03-traefik-svc.yaml

# 04-traefik-deployment.yaml
kubectl --context kind-tmaurice apply -f ./04-traefik-deployment.yaml

# 05-traefik-ingressroutes.yaml
kubectl --context kind-tmaurice apply -f ./05-traefik-ingressroutes.yaml

# 07-local-path-provisioner.yaml
kubectl --context kind-tmaurice apply -f ./07-local-path-provisioner.yaml

# 08-chmod-job.yaml
kubectl --context kind-tmaurice apply -f ./08-chmod-job.yaml

# 09-service-accounts.yaml
kubectl --context kind-tmaurice apply -f ./09-service-accounts.yaml

# 10-metrics-server.yaml"
kubectl --context kind-tmaurice apply -f ./10-metrics-server.yaml

# Installs the metrics server
kubectl --context kind-tmaurice apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# CORRECTIONS
# Put the follow flag “- --kubelet-insecure-tls=true” under the args section of the deployment
kubectl --context kind-tmaurice edit deployment metrics-server -n kube-system

# Install stuff via Helm

# adding repo dashboard
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
# adding repo prometheus
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
# updating repo info
helm repo update

# install dashboard
helm install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard \
    --namespace kubernetes-dashboard \
    --set protocolHttp=true \
    --set serviceAccount.create=false \
    --set serviceAccount.name=admin-user \
    --set metricsScraper.enabled=true

# install prometheus
helm install prometheus -n monitoring prometheus-community/kube-prometheus-stack
```

Dashboard Services:

- Traefik: `http://traefik.0a0f122c.nip.io`
- Kubernetes Dashboard: `http://dashboard.0a0f122c.nip.io`
- Grafana: `http://grafana.0a0f122c.nip.io`

Grafana credentials:

```sh
kubectl get secret -n monitoring prometheus-grafana -oyaml | grep admin-user| cut -d: -f2|tr -d \  | base64 -d
kubectl get secret -n monitoring prometheus-grafana -oyaml | grep admin-password| cut -d: -f2|tr -d \  | base64 -d
```

## Applications test

```sh
kubectl --context kind-tmaurice apply -f ./test.apps
```

App interfaces:

- WhoAmI: `http://whoami.0a0f122c.nip.io`
- TinyWeb: `http://tinyweb.0a0f122c.nip.io`

## That's all

...folks!!!
