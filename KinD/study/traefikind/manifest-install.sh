#!/bin/bash

echo "====== Applies the manifests"

echo "====== 000-namespaces.yaml"
kubectl --context kind-traefikind apply -f manifest/000-namespaces.yaml
sleep 5

echo "====== 010-traefik-crds.yaml"
kubectl --context kind-traefikind apply -f manifest/010-traefik-crds.yaml
sleep 15

echo "====== 020-traefik-rbac.yaml"
kubectl --context kind-traefikind apply -f manifest/020-traefik-rbac.yaml
sleep 5

echo "====== 030-traefik-svc.yaml"
kubectl --context kind-traefikind apply -f manifest/030-traefik-svc.yaml
sleep 5

echo "====== 040-traefik-deployment.yaml"
kubectl --context kind-traefikind apply -f manifest/040-traefik-deployment.yaml
sleep 5

echo "====== 050-traefik-ingressroutes.yaml"
kubectl --context kind-traefikind apply -f manifest/050-traefik-ingressroutes.yaml
sleep 5

echo "====== 060-local-path-provisioner.yaml"
kubectl --context kind-traefikind apply -f manifest/060-local-path-provisioner.yaml
sleep 5

echo "====== 070-chmod-job.yaml"
kubectl --context kind-traefikind apply -f manifest/070-chmod-job.yaml
sleep 10

echo "====== 080-service-accounts.yaml"
kubectl --context kind-traefikind apply -f manifest/080-service-accounts.yaml
sleep 10

echo "====== 090-metrics-server.yaml"
kubectl --context kind-traefikind apply -f manifest/090-metrics-server.yaml
sleep 10

echo "all done!!!"
