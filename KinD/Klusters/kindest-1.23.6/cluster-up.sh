#!/bin/bash

export INSTALL_PROM=no

# 
echo "====== Create the cluster"
if ! kind create cluster --config manifest.bundle/cluster.yaml; then
    exit 1
fi;

# 
echo "====== Untaint the master"
kubectl --context kind-tmaurice taint nodes --all node-role.kubernetes.io/master- || true

# 
echo "====== Applies the manifests"
echo "====== 00-namespaces.yaml"
kubectl --context kind-tmaurice apply -f manifest.bundle/00-namespaces.yaml

echo "====== 00-traefik-crds.yaml"
kubectl --context kind-tmaurice apply -f manifest.bundle/00-traefik-crds.yaml
sleep 10

echo "====== 02-traefik-rbac.yaml"
kubectl --context kind-tmaurice apply -f manifest.bundle/02-traefik-rbac.yaml
sleep 5

echo "====== 03-traefik-svc.yaml"
kubectl --context kind-tmaurice apply -f manifest.bundle/03-traefik-svc.yaml

echo "====== 04-traefik-deployment.yaml"
kubectl --context kind-tmaurice apply -f manifest.bundle/04-traefik-deployment.yaml

echo "====== 05-traefik-ingressroutes.yaml"
kubectl --context kind-tmaurice apply -f manifest.bundle/05-traefik-ingressroutes.yaml

echo "====== 07-local-path-provisioner.yaml"
kubectl --context kind-tmaurice apply -f manifest.bundle/07-local-path-provisioner.yaml

echo "====== 08-chmod-job.yaml"
kubectl --context kind-tmaurice apply -f manifest.bundle/08-chmod-job.yaml

echo "====== 09-service-accounts.yaml"
kubectl --context kind-tmaurice apply -f manifest.bundle/09-service-accounts.yaml

echo "====== 10-metrics-server.yaml"
kubectl --context kind-tmaurice apply -f manifest.bundle/10-metrics-server.yaml
sleep 10

# 
echo "====== Installs the metrics server"
kubectl --context kind-tmaurice apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
sleep 10

# Install stuff via Helm
echo "====== Install stuff via Helm"
echo "====== adding repo dashboard"
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
sleep 10
echo "====== adding repo prometheus"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
sleep 10
echo "====== updating repo info"
helm repo update
sleep 10
echo "====== install dashboard"
helm install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard \
    --namespace kubernetes-dashboard \
    --set protocolHttp=true \
    --set serviceAccount.create=false \
    --set serviceAccount.name=admin-user \
    --set metricsScraper.enabled=true
sleep 10


if [ "${INSTALL_PROM}" = "yes" ]; then
    helm install prometheus -n monitoring prometheus-community/kube-prometheus-stack
    sleep 10
fi;

# kubectl apply -f vault
# sleep 5

echo "====== "
echo "====== Traefik: http://traefik.localhost"
echo "====== Dashboard: http://dashboard.localhost"
if [ "${INSTALL_PROM}" = "yes" ]; then
    echo "====== http://grafana.localhost credentials: $(kubectl get secret -n monitoring prometheus-grafana -oyaml | grep admin-user| cut -d: -f2|tr -d \  | base64 -d):$(kubectl get secret -n monitoring prometheus-grafana -oyaml | grep admin-password| cut -d: -f2|tr -d \  | base64 -d)\n"
fi;

# echo "====== The vault unlock secret (root token) lives in the vault/vault-unlock secret, to get the root token wait up to one minute then run"
# echo "======   kubectl get secret -n vault vault-unlock -ojson | jq -r .data.value | base64 -d | jq -r .root_token"
