# Lightweight Development Kubernetes Options: K3d Ingress Demo with Traefik

In this experiment we will cover a Ingress feature in K3D.

The documentations used was:

- https://k3d.io/usage/guides/exposing_services/
- https://docs.giantswarm.io/advanced/ingress/configuration/

Scenary:

- 2 simple app
- Docker sample static site, and
- Hostname info as result
- Static site response to IP from host
- Hostname response for domain "tarso.io"
- Don't forget to put the domain on "hosts" file

Manifests:

- ```k3demo0.yaml``` file is the static site
- ```k3demo1.yaml``` file is the hostname info
- ```k3dtraefil.yaml``` file is the Ingress routes
