#!/bin/bash

set +e

echo "Deploying traefik components..."
traefik_files=("namespaces" "clusterroles" "deployments" "services") # removed  "tracing"
for f in ${traefik_files[@]}; do
  envsubst < traefik/${f}.yaml | kubectl apply -f -
done
