# Deploying Redis Enterprise on Kubernetes

How to deploy Redis Enterprise on Kubernetes using the Redis Enterprise Operator. The Redis Enterprise Operator supports two Custom Resource Definitions (CRDs):

- Redis Enterprise Cluster (REC): an API to create Redis Enterprise clusters. Note that only one cluster is supported per operator deployment.
- Redis Enterprise Database (REDB): an API to create Redis databases running on the Redis Enterprise cluster. Note that the Redis Enterprise Operator is namespaced. High level architecture and overview of the solution can be found [HERE](https://docs.redislabs.com/latest/platforms/kubernetes/).

> ```https://github.com/RedisLabs/redis-enterprise-k8s-docs```

