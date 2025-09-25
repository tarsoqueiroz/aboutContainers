#! /bin/sh

# Expose k3d node port to localhost for testing (if you are using k3d on a mac)
#  k3d cluster create kustomize-test --servers=2 --agents=2 --port="30000-30010:30000-30010@loadbalancer"

# Create a namespace for the lecture
kubectl create ns v112

# Set the current namespace to lec-12
kubectl config set-context --current --namespace=v112

# Apply the kustomization to the cluster
kubectl apply -k .

# Get the postgres database ip address
kubectl get svc/v112-mysql --output="jsonpath={.spec.clusterIP}"
