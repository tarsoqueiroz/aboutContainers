#!/bin/bash

set +e

echo "Installing Traefik components:"
traefik_files=("namespaces" "clusterroles" "deployments" "services" tracing)
for f in ${traefik_files[@]}; do
  envsubst < traefik/${f}.yaml | kubectl apply -f -
done
