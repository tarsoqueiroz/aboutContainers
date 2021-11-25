# How to Create a Kubernetes Cluster and Load Balancer for Local Development

> [How to Create a Kubernetes Cluster and Load Balancer for Local Development](https://dzone.com/articles/how-to-create-a-kubernetes-cluster-and-load-balanc)

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [k3d (v4.4.6)](https://github.com/rancher/k3d/releases)
- [jq](https://stedolan.github.io/jq/) is a lightweight and flexible command-line JSON processor
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [lens](https://k8slens.dev/) (optional) 

## Setup

Create the Cluster and validate it's creation:

```Shell
# create the k3d cluster
k3d cluster create local-k8s --servers 1 --agents 3 --k3s-server-arg --no-deploy=traefik --wait

# set kubeconfig to access the k8s context
export KUBECONFIG=$(k3d kubeconfig write local-k8s)

# validate the cluster master and worker nodes
kubectl get nodes
```

Determine your Load Balancer's ingress range by obtaining it's cidr block. This range will depend on the Docker network that your k3d cluster leverages. The script below will help determine and prescribe a suggested range.

```Shell
# inspect containers
docker container ls

# inspect network create for cluster
docker network ls
docker network inspect k3d-local-k8s | jq

# determine loadbalancer ingress range
cidr_block=$(docker network inspect k3d-local-k8s | jq '.[0].IPAM.Config[0].Subnet' | tr -d '"')
echo $cidr_block

cidr_base_addr=${cidr_block%???}
echo $cidr_base_addr

ingress_first_addr=$(echo $cidr_base_addr | awk -F'.' '{print $1,$2,255,0}' OFS='.')
echo $ingress_first_addr
ingress_last_addr=$(echo $cidr_base_addr | awk -F'.' '{print $1,$2,255,255}' OFS='.')
echo $ingress_last_addr
ingress_range=$ingress_first_addr-$ingress_last_addr
echo $ingress_range
```

Deploy the Load Balancer, which leverages MetalLB:

```Shell
# deploy metallb 
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.10.2/manifests/namespace.yaml

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.10.2/manifests/metallb.yaml

```

Create a manifest file `metallb-configmap.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - [insert here the value of $ingress_range]
```

Apply this manifest:

```Shell
# configure metallb ingress address range
kubectl apply -f ./metallb-configmap.yaml
```

## Validation

Create an Nginx test deployment and expose via a Load Balancer. If the Load Balancer is working correctly, an external ip address should be assigned by Metallb.

```Shell
# create a deployment (i.e. nginx)
kubectl create deployment nginx --image=nginx

# expose the deployments using a LoadBalancer
kubectl expose deployment nginx --port=80 --type=LoadBalancer

# obtain the ingress external ip
external_ip=$(kubectl get svc nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# test the loadbalancer external ip
curl $external_ip
```

## Teardown

Destroy the cluster

```Shell
k3d cluster delete local-k8s
```

## Conclusion

This post has gone over one of many ways to deploy a Kubernetes cluster to a local development environment. You can find an accompanying Github repository [here](https://github.com/keunlee/k3d-metallb-starter-kit) for reference source.
