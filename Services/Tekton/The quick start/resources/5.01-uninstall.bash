kubectl config use kind-tekton-cluster
version="v0.25.3"
kubectl delete --filename https://storage.googleapis.com/tekton-releases/triggers/previous/${version}/release.yaml
kubectl delete --filename https://storage.googleapis.com/tekton-releases/triggers/previous/${version}/interceptors.yaml

