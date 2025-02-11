# Traefik over Kind

This repository has the required configuration files to run Traefik over kind.

The manifests for traefik are mainly inspired in [this guide](https://doc.traefik.io/traefik/getting-started/quick-start-with-kubernetes/) however some tweaks have been added to be able to expose the ingress to the host network when using kind in mac/windows (based on [this guide](https://kind.sigs.k8s.io/docs/user/ingress/)).

## References

- [Traefik Releases](https://github.com/traefik/traefik/releases)
- [Traefik Helm Chart: values.yaml](https://github.com/traefik/traefik-helm-chart/blob/master/traefik/values.yaml)
- [Deploy K8ssandra and Traefik with Kind](https://docs.k8ssandra.io/tasks/connect/ingress/kind-deployment/)
- [Getting started with Kubernetes Gateway API and Traefik](https://traefik.io/blog/getting-started-with-kubernetes-gateway-api-and-traefik/)
- [Getting started with Kubernetes Gateway API and Traefik II](https://community.traefik.io/t/getting-started-with-kubernetes-gateway-api-and-traefik/23601)

## Getting started

First we will create a kind cluster by running `make build`.

Once the cluster is ready we will deploy the applications by running `make deploy` and after that we will be able to access the dashboard through <http://localhost:8080> and do some curls to the sample app:

```console
# Successful request:
curl http://localhost
```

Once you are done you can cleanup the environment running `make cleanup`.

## Requirements

- kind
- kubectl

## References

- [Traefik over Kind](https://github.com/jcchavezs/traefik-kind/blob/main/README.md)
- [Kind: Ingress](https://kind.sigs.k8s.io/docs/user/ingress/)
- [Traefik & Kubernetes](https://doc.traefik.io/traefik/providers/kubernetes-ingress/)
- [Traefik as K8S Ingress Controller](https://medium.com/@dusansusic/traefik-ingress-controller-for-k8s-c1137c9c05c4)

## Track

```sh
# 
make build



# 
make install

# 
make deploy

# 
make deployhigh

# 
make deploytwi1

# 
make deploytwi2

# 
make deploytwi3

# 
make undeplo

# 
make undeployhigh

# 
make undeploytwi

# 
make undeploytwi

# 
make undeploytwi

# 
make destroy
```
