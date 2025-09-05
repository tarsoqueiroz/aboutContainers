kubectl config use kind-tekton-cluster
version="v0.25.3"
kubectl apply --filename https://storage.googleapis.com/tekton-releases/triggers/previous/${version}/release.yaml
kubectl apply --filename https://storage.googleapis.com/tekton-releases/triggers/previous/${version}/interceptors.yaml

