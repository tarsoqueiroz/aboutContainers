# [NGINX Gateway Fabric](https://docs.nginx.com/nginx-gateway-fabric/)

NGINX Gateway Fabric is an open source project that provides an implementation of the [Gateway API](https://gateway-api.sigs.k8s.io/) using [NGINX](https://nginx.org/) as the data plane. The goal of this project is to implement the core Gateway APIs – Gateway, GatewayClass, HTTPRoute, GRPCRoute, TCPRoute, TLSRoute, and UDPRoute – to configure an HTTP or TCP/UDP load balancer, reverse proxy, or API gateway for applications running on Kubernetes. NGINX Gateway Fabric supports a subset of the Gateway API.

## Table of Contents

- [Before you begin](#before-you-begin)
- [Sources and references](#sources-and-references)
- [NGINX Gateway Fabric: Get started](#nginx-gateway-fabric-get-started)

## Before you begin

To complete this guides, you need the following prerequisites installed:

- [Go 1.16](https://go.dev/dl/) or newer, which is used by kind
- [Docker](https://docs.docker.com/get-started/get-docker/), for creating and managing containers
- [kind](https://kind.sigs.k8s.io/#installation-and-usage), which allows for running a local Kubernetes cluster using Docker
- [kubectl](https://kubernetes.io/docs/tasks/tools/), which provides a command line interface (CLI) for interacting with Kubernetes clusters
- [Helm 3.0](https://helm.sh/docs/intro/install/) or newer to install NGINX Gateway Fabric
- [curl](https://curl.se/), to test the example application

## Sources and references

- [NGINX Gateway Fabric: Github](https://github.com/nginx/nginx-gateway-fabric)
- [Descomplicando Gateway API no Kubernetes: Parte 1](https://linuxtips.io/descomplicando-gateway-api-no-kubernetes/)
- [NGINX Gateway Fabric: Application routes using HTTP matching conditions (Advanced Routing)](https://docs.nginx.com/nginx-gateway-fabric/how-to/traffic-management/advanced-routing/)

## [NGINX Gateway Fabric: Get started](https://docs.nginx.com/nginx-gateway-fabric/get-started/)

This is a guide for getting started with NGINX Gateway Fabric. It explains how to:

- Set up a kind (Kubernetes in Docker) cluster
- Install NGINX Gateway Fabric with NGINX
- Test NGINX Gateway Fabric with an example application

By following the steps in order, you will finish with a functional NGINX Gateway Fabric cluster.

### Set up a kind cluster

- [`kind-nginx-gs.yaml`](./manifests/kind-nginx-gs.yaml)

> ***Note:*** The two containerPort values are used to later configure a NodePort.

```bash
kind create cluster --config ./manifests/kind-nginx-gs.yaml
```

### Install NGINX Gateway Fabric

Add Gateway API resources:

```bash
kubectl kustomize "https://github.com/nginx/nginx-gateway-fabric/config/crd/gateway-api/standard?ref=v1.6.1" | kubectl apply -f -
```

> ***Note:*** Release versions on this [table list](https://github.com/nginx/nginx-gateway-fabric/tree/release-1.6#technical-specifications).

Install the Helm chart:

```bash
helm install ngf oci://ghcr.io/nginx/charts/nginx-gateway-fabric --create-namespace -n nginx-gateway --set service.create=false
```

Set up a NodePort:

- [`nginx-gs-nodeport-config.yaml`](./manifests/nginx-gs-nodeport-config.yaml)

> ***Note:*** The highlighted nodePort values should equal the containerPort values from nginx-kind.yaml when you created the kind cluster.

```bash
kubectl apply -f ./manifests/nginx-gs-nodeport-config.yaml
```

### Create an example application

> ***Note:*** The originals YAML code in the following sections can be found in the [cafe-example folder](https://github.com/nginx/nginx-gateway-fabric/tree/main/examples/cafe-example) of the GitHub repository.

Create the application resources:

- [`nginx-gs-coffe.yaml`](./manifests/nginx-gs-coffee.yaml)

```bash
kubectl apply -f ./manifests/nginx-gs-cafe.yaml
```

Create Gateway and HTTPRoute resources:

- [`nginx-gs-gateway.yaml`](./manifests/nginx-gs-gateway.yaml)

```bash
kubectl apply -f ./manifests/nginx-gs-gateway.yaml
```

- [`nginx-gs-coffee-routes.yaml`](./manifests/nginx-gs-coffee-routes.yaml)

```bash
kubectl apply -f ./manifests/nginx-gs-coffee-routes.yaml
```

### Verify the configuration

```bash
kubectl get service --all-namespaces

kubectl describe httproutes.gateway.networking.k8s.io 

kubectl describe gateways
```

### Test NGINX Gateway Fabric

```bash
#### --resolve on curl is required to resolve the hostname to the IP address of the kind cluster
curl --resolve coffee.0a0f122c.nip.io:8080:127.0.0.1   http://coffee.0a0f122c.nip.io:8080/coffee
curl --resolve coffee.0a0f122c.nip.io:8080:10.15.18.44 http://coffee.0a0f122c.nip.io:8080/coffee

curl http://coffee.example.com:8080/coffee
curl http://coffee.example.com:8080/tea
```

## NGF Installation: Setup a kind cluster

Using the basic ports (80 and 443) for NGINX Gateway Fabric:

- [`kind-nginx-ngfb.yaml`](./manifests/kind-nginx-ngfb.yaml)

> ***Note:*** The two containerPort values are used to later configure a NodePort.

```bash
kind create cluster --config ./manifests/kind-nginx-ngfb.yaml
```

## [NGF Installation: with HELM](https://docs.nginx.com/nginx-gateway-fabric/installation/installing-ngf/helm/)

## [NGF Installation: with Manifests](https://docs.nginx.com/nginx-gateway-fabric/installation/installing-ngf/manifests/)

## [NGF How-to: Routing traffic to applications](https://docs.nginx.com/nginx-gateway-fabric/how-to/traffic-management/routing-traffic-to-your-app/)

You can route traffic to your Kubernetes applications using the Gateway API and NGINX Gateway Fabric. Whether you’re managing a web application or a REST backend API, you can use NGINX Gateway Fabric to expose your application outside the cluster.



## Application routes using HTTP matching conditions

### Coffee applications

#### Deploy the Coffee applications

- [`nginx-coffee-v1v2.yaml`](./nginx-coffee-v1v2.yaml)

```bash
kubectl apply -f nginx-coffee-v1v2.yaml
```

#### Deploy the Gateway API Resources for the Coffee applications

- [`nginx-adv-gateway.yaml`](./nginx-adv-gateway.yaml)

```bash
kubectl apply -f nginx-adv-gateway.yaml
```

- [`nginx-adv-routes.yaml`](./nginx-adv-routes.yaml)

```bash
kubectl apply -f nginx-adv-routes.yaml
```

#### Send traffic to Coffee

```bash
#### --resolve on curl is required to resolve the hostname to the IP address of the kind cluster
curl --resolve cafe.0a0f122c.nip.io:8080:127.0.0.1   http://cafe.0a0f122c.nip.io:8080/coffee
curl --resolve cafe.0a0f122c.nip.io:8080:10.15.18.44 http://cafe.0a0f122c.nip.io:8080/coffee
curl http://cafe.0a0f122c.nip.io:8080/coffee

curl --resolve cafe.0a0f122c.nip.io:8080:10.15.18.44 http://cafe.0a0f122c.nip.io:8080/coffee -H "version:v2"
curl http://cafe.0a0f122c.nip.io:8080/coffee -H "version:v2"

curl --resolve cafe.0a0f122c.nip.io:8080:10.15.18.44 http://cafe.0a0f122c.nip.io:8080/coffee?TEST=v2
curl http://cafe.0a0f122c.nip.io:8080/coffee?TEST=v2
```

### Tea applications

#### Deploy the Tea applications

- [`nginx-tea-v1post.yaml`](./nginx-tea-v1post.yaml)

```bash
kubectl apply -f nginx-tea-v1post.yaml
```

#### Deploy the HTTPRoute for the Tea services

- [`nginx-adv-tea-routes.yaml`](./nginx-adv-tea-routes.yaml)

```bash
kubectl apply -f nginx-adv-tea-routes.yaml
```

#### Send traffic to Tea

```bash
#### --resolve on curl is required to resolve the hostname to the IP address of the kind cluster

curl --resolve cafe.0a0f122c.nip.io:8080:127.0.0.1   http://cafe.0a0f122c.nip.io:8080/tea
curl --resolve cafe.0a0f122c.nip.io:8080:10.15.18.44 http://cafe.0a0f122c.nip.io:8080/tea
curl http://cafe.0a0f122c.nip.io:8080/tea

curl --resolve cafe.0a0f122c.nip.io:8080:10.15.18.44 http://cafe.0a0f122c.nip.io:8080/tea -X POST
curl http://cafe.0a0f122c.nip.io:8080/tea -X POST
```

## That's all

...folks!!!
