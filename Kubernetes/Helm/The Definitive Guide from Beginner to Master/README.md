# HELM: The Definitive Guide from Beginner to Master

## About

> `https://www.udemy.com/course/definitive-helm-course-beginner-master`

Install, manage, create, and deploy Helm charts in Kubernetes clusters! Learn the Helm CLI, Hooks, Plugins and more!

What you learn:

- Build Helm charts from scratch using best practices and optimal chart structures
- Customize existing Helm charts to perfectly fit your application’s requirements
- Master Go Template syntax to produce dynamic, maintainable Kubernetes manifests
- Confidently handle configuration values and apply overrides to achieve flexible deployments
- Perform seamless version upgrades to keep your deployments current without downtime
- Execute rapid rollbacks to previous stable releases for immediate recovery
- Maintain stable, scalable Kubernetes deployments through Helm-driven best practices
- Implement Helm Hooks for automating pre- and post-deployment tasks
- Add testing Hooks to validate chart quality and ensure robust releases
- Leverage Library charts to promote reusability and reduce duplication in deployments
- Work with Helm Plugins to extend the functionality of Helm and achieve even more with the tool

## Introduction

> [Github: The Definitive Helm Course: From Beginner to Master](https://github.com/lm-academy/helm-course)
> [Github: Config Store app](https://github.com/lm-academy/config-store)
> [Helm slides](./resources/helm-slides.pdf)

## What's Helm?

### Helm: The Package Manager for Kubernetes

Think of it as `apt-get` or `yum` **for your Kubernetes cluster**.

You've spent decades deploying complex applications (web servers, databases, load balancers). Manually crafting 20+ YAML files for a single app (Deployments, Services, ConfigMaps, Secrets, Ingress, etc.) is tedious, error-prone, and impossible to version or share effectively.

Helm solves this.

### The Core Concept: Charts

A **Chart** is a Helm package. It's a collection of pre-configured Kubernetes resource files (your YAMLs) bundled together with default values and metadata.

- **It's the equivalent of a `.deb` or `.rpm` file**. It contains everything needed to deploy an application.
- Charts can be stored in public or private **Repositories** (like a package repository).

### The Power: Templating and Values

This is where your development knowledge clicks in. Helm uses the Go templating language.

- You don't write static YAML. You write **templates** (`deployment.yaml.tpl`, `configmap.yaml.tpl`).
- You extract the dynamic, environment-specific settings (e.g., `replicaCount`, `service.port`, `database.url`) into a separate `values.yaml` file.

The Helm CLI then combines the template (deployment.yaml.tpl) + the values (values.yaml) to generate the final, valid Kubernetes YAML and applies it to the cluster.

### Benefits and Limitations

### Helm vs Kustomize

### Helm arqchitecture

## Install

### Kind for Local Kubernetes cluster

```sh
kind create cluster --config ./manifests/k8scluster.yaml -n helmlab

kind get clusters 

kubectl get nodes -o wide
```

### Helm

> `https://github.com/tarsoqueiroz/fastITips/tree/primary/Kubernetes/Helm`

```sh
curl -LO https://get.helm.sh/helm-v3.14.0-linux-amd64.tar.gz

tar -zxvf ./helm-v3.14.0-linux-amd64.tar.gz

sudo install -o root -g root -m 0755 linux-amd64/helm /usr/local/bin/helm
rm -rf linux-amd64

helm completion bash | sudo tee /etc/bash_completion.d/helm_completion
```

### VSCode: install and configure

Extensions:

- **Kubernetes**: Visual Studio Code Kubernetes Tools (by Microsoft)
- **Prettier - Code formatter**: Prettier Formatter for Visual Studio Code

## Helm Fundamentals

## Conclusion

## That's all

...folks
