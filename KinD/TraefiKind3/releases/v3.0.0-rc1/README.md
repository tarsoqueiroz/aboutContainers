# Traefik over Kind

This repository has the required configuration files to run Traefik over kind.

The manifests for traefik are mainly inspired in [this guide](https://doc.traefik.io/traefik/getting-started/quick-start-with-kubernetes/) however some tweaks have been added to be able to expose the ingress to the host network when using kind in mac/windows (based on [this guide](https://kind.sigs.k8s.io/docs/user/ingress/)).

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
