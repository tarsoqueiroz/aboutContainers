#!/usr/bin/env bash

set -e

tekton_cluster="tekton-cluster"
tekton_version="v0.52.0"

kubectl config use "kind-$tekton_cluster"
kubectl config current-context

kubectl apply --filename "https://storage.googleapis.com/tekton-releases/pipeline/previous/$tekton_version/release.yaml"