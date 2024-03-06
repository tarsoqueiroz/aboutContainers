# Manage Kubernetes locally with RKE DIND

## About

> `https://the.binbashtheory.com/posts/rke-dind/`

## Environment

```sh
# To create
rke up --dind --config ./resources/cluster1.yaml

rke up --dind --config ./resources/cluster2.yaml

# To delete
rke remove --dind --config ./resources/cluster1.yaml

rke remove --dind --config ./resources/cluster2.yaml


```
