#!/usr/bin/env bash
set -euo pipefail

CLUSTER="kind-cilium"

# Control-plane: cpu=1000m (1 vCPU) / memory=1024Mi
docker update \
  --cpus="1" \
  --memory="1024m" --memory-swap="1024m" \
  "${CLUSTER}-control-plane"

# Workers: cpu=2000m (2 vCPU) / memory=4096Mi cada
for node in $(docker ps --filter "label=io.x-k8s.kind.cluster=${CLUSTER}" \
              --format "{{.Names}}" | grep worker); do
  docker update \
    --cpus="2" \
    --memory="4096m" --memory-swap="4096m" \
    "${node}"
done

echo "Limites aplicados. Reiniciando containers para que o kubelet/cAdvisor releia o cgroup..."
docker restart "${CLUSTER}-control-plane" $(docker ps --filter "label=io.x-k8s.kind.cluster=${CLUSTER}" --format "{{.Names}}" | grep worker)
