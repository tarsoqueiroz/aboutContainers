#!/usr/bin/env bash

set -e

tekton_cluster="tekton-cluster"

# optionally set memory and cpu
#podman machine stop
#podman machine set --cpus=2
#podman machine set -m=4096
#podman machine start

kind delete clusters "$tekton_cluster"
kind create cluster --name "$tekton_cluster"

kubectl config use "kind-$tekton_cluster"
kubectl config current-context