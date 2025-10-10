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

### Installing Helm Charts

Below you will find a series of steps you can follow in case you start seeing Image Pull Errors when installing the Helm charts. There are a couple of options you could adopt here:

#### Set the Docker repositories to point to the `bitnamilegacy` registry.

This is a short-term solution that will enable you to continue working with the exact same chart versions I use in the videos. However, it does require you to explicitly set a couple of values when running Helm commands. We haven't explored this at this specific point of the course, but the process is fairly straightforward:

1. Create a new YAML file, for example `wp-repo-overrides.yaml`.
2. For the Wordpress chart, add the following contents to the file:

```sh
    image:
      registry: docker.io
      repository: bitnamilegacy/wordpress
     
    mariadb:
      image:
        registry: docker.io
        repository: bitnamilegacy/mariadb
```

3. Once the file is created, add the following to the `helm template`, `helm install`, and `helm upgrade` commands we execute: `--values <path to file>`. For example:

- `helm template bitnami/wordpress` becomes `helm template bitnami/wordpress --values wp-repo-overrides.yaml`
- `helm install local-wp bitnami/wordpress` becomes `helm install local-wp bitnami/wordpress --values wp-repo-overrides.yaml`

This will enable you to continue using the same chart versions from the lectures for the moment, and you should still be able to install the applications on your Kubernetes cluster.

. **⚠️ IMPORTANT:** You will also need to set these values at later points in the course when we discuss chart dependencies and Helm plugins.

2. Pick another Helm chart to follow along.

This is perhaps the more stable option, although also far from optimal for the time being. It simply requires you to pick another Helm chart instead of the Wordpress one we will use in the upcoming lectures. This will lead to some divergence between what I demonstrate on the videos and the exact commands you need to execute, but perhaps this can also work as a good learning opportunity! Here are a few suggestions:

- **Grafana:** [`https://artifacthub.io/packages/helm/grafana/grafana`](https://artifacthub.io/packages/helm/grafana/grafana)
- **Prometheus:** [`https://artifacthub.io/packages/helm/prometheus-community/prometheus`](https://artifacthub.io/packages/helm/prometheus-community/prometheus)
- **Kubernetes dashboard:** [`https://artifacthub.io/packages/helm/k8s-dashboard/kubernetes-dashboard`](https://artifacthub.io/packages/helm/k8s-dashboard/kubernetes-dashboard)

In practice, this means that you should follow the installation instructions from the respective chart instead of the ones I execute in the terminal.

### Managing Helm repositories

```sh
# list repos
helm repo list
# add repository
helm repo add bitnami https://charts.bitnami.com/bitnami
# 
helm repo list
# update info about charts on repo
helm repo update 
# search specific chart
helm search repo wordpress
helm search repo prometheus
```

Go to `https://artifacthub.io/packages/helm/prometheus-community/prometheus?modal=install` (result search for `prometheus`). Add repository on tips.

```sh
# add repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
# show list of repos
helm repo list
# search prometheus
helm search repo prometheus
# limit col width
helm search repo prometheus --max-col-width 60
# show info about specific chart
helm show chart bitnami/wordpress
# search repo by functionality
helm search repo cms
# show versions of a chart
helm search repo wordpress --versions
# show readm (instructions) of chart
helm show readme bitnami/wordpress
# help
helm repo --help
# update repo info
helm repo update
# show repos
helm repo list
# remove repo
helm repo remove bitnami
# show repos
helm repo list
# show charts
helm search repo prometheus
# add repo
helm repo add bitnami https://charts.bitnami.com/bitnami
# show repos
helm repo list
```

### Installing the Wordpress Helm chart

```sh
# 
helm repo list
# 
kubectl version
# 
kubectl config current-context
# 
helm search repo wordpress
# 
helm install --help
# 
helm install local-wp bitnami/wordpress --version=26.0.0
# 
kubectl get pod -o wide
# 
kubectl get svc
# 
kubectl describe secrets local-wp-wordpress 
# 
kubectl get secrets 
# 
kubectl get pod -o wide
# 
kubectl describe pod local-wp-wordpress-668c4cd775-7ff5k 
# 
kubectl get deployments.apps 
# 
kubectl expose deployment local-wp-wordpress --type=NodePort
# 
kubectl expose deployment local-wp-wordpress --type=NodePort --name=local-wp
# 
kubectl get svc
```

### Exploring the default Wordpress chart configuration

```sh
# 
kubectl get pod
# 
kubectl get secrets local-wp-wordpress -o jsonpath='{.data.wordpress-password}' | base64 -d
# 
helm get values local-wp 
# 
helm get values local-wp --all
# 
helm get notes local-wp 
# 
helm get metadata local-wp 
```

### Uninstalling Helm charts

```sh
# 
helm list
# 
helm uninstall local-wp 
# 
kubectl get pod
# 
kubectl get svc
# 
kubectl delete svc local-wp 
# 
kubectl get pv,pvc
# 
kubectl describe pvc data-local-wp-mariadb-0 
# 
kubectl describe storageclasses.storage.k8s.io standard 
# 
kubectl delete pvc data-local-wp-mariadb-0 
# 
kubectl get pv,pvc
# 
kubectl get secrets 
```

### Cleaning up Kubernetes resources

```sh
#
helm install tq-wp bitnami/wordpress --version=23.1.20
#
kubectl get pod
#
kubectl describe pods tq-wp-wordpress-6884b755c7-jlhnf 
#
kubectl get secrets 
#
kubectl get secret tq-wp-mariadb 
#
kubectl describe secret tq-wp-mariadb 
#
kubectl get secret --namespace default tq-wp-wordpress -o jsonpath="{.data.wordpress-password}" | base64 -d
#
kubectl get secret --namespace default tq-wp-mariadb -o jsonpath='{.data.mariadb-password}' | base64 -d
#
helm uninstall tq-wp 
#
kubectl get pvc
#
kubectl delete pvc data-tq-wp-mariadb-0 
#
kubectl get pvc
#
kubectl get secret,pod,deploy,svc
```

### Setting custom values via the Helm cli

```sh
#
helm install local-wp bitnami/wordpress --version=23.1.20 --set "mariadb.auth.rootPassword=myawesomepassword" --set "mariadb.auth.password=myuserpassword"
#
kubectl get pod
#
kubectl logs local-wp-wordpress-544b68769-pztl7 
#
kubectl get secrets 
#
kubectl get secret local-wp-mariadb -o jsonpath='{.data.mariadb-password}' | base64 -d
#
kubectl get secret local-wp-mariadb -o jsonpath='{.data.mariadb-root-password}' | base64 -d
#
helm get values local-wp 
#
helm uninstall local-wp 
#
kubectl get pod,deploy,secret
#
kubectl get pv,pvc
```

### Setting custom values via files

```sh
#
kubectl create secret generic custom-wp-credentials --from-literal=wordpress-password=lauropassword
#
kubectl get secrets 
#
helm install local-wp bitnami/wordpress --version=23.1.20 --values resources/custom-values.yaml 
#
helm get values local-wp 
#
kubectl get pods
#
kubectl get deployments.apps 
#
helm list
```

### Upgrading Helm releases: Setting new values

```sh
#
helm list
#
helm upgrade --reuse-values --values ./resources/custom-values-v2.yaml local-wp bitnami/wordpress --version 23.1.20
#
kubectl get pods
#
helm get values local-wp
#
helm history local-wp 
#
helm get values local-wp 
#
helm get values local-wp --revision 1
#
kubectl get secrets 
```

### Upgrading Helm releases: Settings new values

```sh
#
helm repo update
#
helm search repo bitnami/wordpress --versions
#
helm list
#
helm upgrade --reuse-values --values ./resources/custom-values-v2.yaml local-wp bitnami/wordpress --version 23.1.28
#
kubectl get pods
#
helm history local-wp 
```

### Rollbacks in Helm

```sh
#
helm history local-wp 
#
helm upgrade --reuse-values --values resources/custom-values-v2.yaml --set "image.tag=nonexistent" local-wp bitnami/wordpress --version 23.1.28
#
kubectl get pod
#
kubectl describe pod local-wp-wordpress-7f8dc8694b-f5phl 
#
helm history local-wp
#
helm rollback local-wp 3
#
helm history local-wp
#
kubectl get pod
#
kubectl describe pod local-wp-wordpress-7f8dc8694b-f5phl 
#
kubectl describe pod local-wp-wordpress-859ff4d9bb-l9pmt 
#
kubectl get pod
#
kubectl get rs
#
kubectl get deployments.apps 
#
kubectl delete rs local-wp-wordpress-859ff4d9bb 
#
kubectl delete rs local-wp-wordpress-cf9cbb7d 
#
kubectl get rs
#
kubectl get secrets 
```

### Upgrading Helm releases: Useful CLI flags

```sh
#
kubectl get svc
#
kubectl delete svc local-wp-wordpress 
#
helm upgrade --reuse-values --values ./resources/custom-values-v3.yaml local-wp bitnami/wordpress --version 23.1.28
#
kubectl get pod
#
kubectl get svc
#
helm upgrade --reuse-values --values ./resources/custom-values-v3.yaml local-wp bitnami/wordpress --version 23.1.28
#
kubectl get pod
#
kubectl get svc
#
helm history local-wp 
#
helm upgrade --reuse-values --values resources/custom-values-v3.yaml --set "image.tag=nonexistent" local-wp bitnami/wordpress --version 23.1.28 --atomic --cleanup-on-fail --debug --timeout 2m
#
kubectl get pod
#
helm history local-wp 
#
helm get values local-wp --revision 9
#
helm get values local-wp --revision 8
#
kubectl get rs
#
helm uninstall local-wp 
#
kubectl delete pvc data-local-wp-mariadb-0 
#
kubectl get pv,pvc
#
kubectl get pod,rs,deploy,secret
#
kubectl delete pv pvc-8dd3ab68-de34-4cd9-bc80-459990c73f64 
#
helm list
```

## Creating Our Own Helm Charts

### Helm chart structure and files

```sh
|
|___ charts /
|___ templates /
     |___ tests /
     |___ deploy.yaml
     |___ svc.yaml
     |___ <others>.yaml
     |___ NOTES.txt
     |___ _helpers.tpl
```

Roles and requirements of each file present in the chart:

- `charts/`: Contains any chart dependencies (subcharts). These dependencies should be informed in the `Chart.yaml` file, and will be downloaded and saved locally.
- `templates/`: This directory contains multiple files that are relevant for Helm projects, including the multiple Kubernetes manifest templates that are rendered by Helm.
  - `tests/`: Contains tests to be executed when running the `helm test` command.
  - `NOTES.txt`: It's contents are printed on the screen upon successful chart installation or upgrade.
  - `_helpers.tpl`: Contains template helper functions, which can be used to reduce duplication. Files preceded with an underscore are not included in the final renderin from Helm.

### Creating the first Helm chart

```sh
#
mkdir creating-charts
#
cd creating-charts/
#
mkdir nginx
#
touch nginx/Chart.yaml
#
touch nginx/values.yaml
#
mkdir nginx/templates
#
touch nginx/templates/deployment.yaml
#
touch nginx/templates/service.yaml
#
touch nginx/.helmignore
#
helm template nginx
#
helm lint nginx
#
helm install tq-mynginx nginx
#
kubectl get pods
#
kubectl get svc
#
helm uninstall tq-mynginx 
```

### Go Templates

```sh
#
mkdir intro-go-templating
#
cd intro-go-templating/
#
touch Chart.yaml values.yaml
#
mkdir templates
#
helm template .
#
# add something on sandbox.yaml
#
helm template .
#
# add things on sandbox.yaml and value.yaml
#
helm template .
#
# add things on sandbox.yaml and value.yaml
#
helm template .

# many time
helm template .
```

### Adding first values to `values.yaml` file

```sh
# directory base
cd creating-charts/nginx-v1

# adding values

#
helm template .
```

### Using release and chart information in templates

### Conditionally deploy Kubernetes resources

### Packaging our Helm chart

```sh
#
helm template nginx-v1
#
helm install local-nginx nginx-v1
#
helm list
#
kubectl get deploy,svc,pod,rs
#
helm uninstall local-nginx 
#
helm package --help
#
helm package nginx-v1
#
helm install local-nginx ./nginx-v1-0.1.0.tgz 
#
kubectl get deploy,svc,pod,rs
#
helm uninstall local-nginx 
#
helm list
```

### Publishing our Helm chart with GitHub Pages

Steps to create:

- Create a repository on GitHub
  - Inform `Repository name` and `Description`
  - Set `Public`
  - Set `Add a README file`
  - Unset `Add .gitignore`
  - `License` chose `MIT`
  - `Create repository`
- Select `Settings`
- On left-side menu select `Pages`
  - `Build and deployment`
    - `Source`: select `Deploy form a branch`
    - `Branch`: select `primary`
    - `Save` 
- On left-side menu select `Actions`
  - `Build and deployment`
    - `Source`: select `Deploy form a branch`
    - `Branch`: select `primary`
    - `Save` 
- Git clone this repository
- Copy helm chart for cloned git path
- Git update info
- Verify:
  - On left-side menu select `Actions`
  - On browser: `<repository>/index.yaml`

```sh
# 
git clone https://github.com/tarsoqueiroz/helm-charts.git
# 
cd helm-charts/
# 
cp ../aboutContainers/Kubernetes/Helm/The\ Definitive\ Guide\ from\ Beginner\ to\ Master/creating-charts/nginx-v1-0.1.0.tgz ../helm-charts/.
# 
helm repo index .
# 
ll
# 
cat index.yaml 
# 
git status
# 
git add .
# 
git commit -m"nginx-v1: publish version 0.1.0"
# 
git push
```

### Installing our newly published Helm chart

```sh
# 
helm repo add tarepo https://tarsoqueiroz.github.io/helm-charts/
# 
helm repo list
# 
helm search repo nginx
# 
helm install tarso-nginx tarepo/nginx-v1 
# 
kubectl get deploy,svc,pod,rs
```

### Leveraging the Helm CLI for creating new charts

```sh
helm create backend-app
```

## Go Template Deep-Dive

### Introduction

### Template functions and pipelines

- [Template Function List](https://helm.sh/docs/chart_template_guide/function_list/)
- [`sandbox.yaml.V01`](./creating-charts/templating-deep-dive/templates/_sandbox.v01.yaml)

```sh
helm template .
```

### Named templates

- `_helpers.tpl`

```yaml
{{- define "templating-deep-dive.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "templating-deep-dive.selectorLabels" -}}
app: {{ .Chart.Name }}
release: {{ .Release.Name }}
created-by: "Tarso"
{{- end -}}
```

- Included on manifest`.yaml`

```yaml
...
metadata:
  name: {{ include "templating-deep-dive.fullname" . }}
  labels: 
    {{- include "templating-deep-dive.selectorLabels" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels: 
      {{- include "templating-deep-dive.selectorLabels" . | nindent 6 }}
...
```

### If ad If-Eklse statements

```yaml
...
{{- if .Values.service.enabled }}
kind: Service
apiVersion: v1
.
.
.
{{ end }}
...

...
      containers:
        - name: nginx
          image: "{{ .Values.image.name }}:{{ .Values.image.tag }}"
          {{- if .Values.service.enabled }}
          ports:
            - containerPort: {{ .Values.containerPorts.http }}
          {{- end }}
...

...
spec:
  replicas: {{ if eq .Values.environment "production" -}} 5 {{- else -}} 2 {{- end }}
  selector:
...
```

### Variables

```yaml
...
{{- $defaultName := printf "%s-%s" .Release.Name .Chart.Name }}
{{- .Values.customName | default $defaultName | trunc 63 | trimSuffix "-" -}}
...
```

### Variables' Scope

### Using "range" to iterate over lists

### Using "range" to iterate over dictionaries

### Understanding the "dot" variable

### Using "with" blocks

### Validation functions

### Implementing custom validation logic

## Coding a Key-Value Store API

### Project setup

### Express and app setup

### PostgreSQL setup

### Implement API routes

### Testing, building and pushing the Docker Images

## Managing Chart Dependencies

### What are Subcharts?

### Bootstrap the config store Help chart

- [Subchart](https://github.com/lm-academy/helm-course/tree/main/subcharts)

**⚠️ IMPORTANT I - PostgreSQL Chart Updates ⚠️**

This is a quick note on a recent new Chart version for PostgreSQL that requires a small change in the `values.yaml` file in the upcoming lectures, in case you wish to use the version 16.6.6 or later of the chart.

> **Context:** The [release of version 16.6.0](https://github.com/bitnami/charts/releases/tag/postgresql%2F16.6.0) changed the default value for the `usePasswordFiles` to `true` in the `values.yaml` file. This might break the upcoming implementation where we rely on environment variables instead of password files.

How to proceed? To address this with minimal changes, there are two ways we can proceed:

1. Use the same chart version as the lectures

Set the chart version to 16.2.2 in the chart dependencies list. While this does have the drawback of using an older version, it is more than enough to follow along with the lectures.

2. Explicitly set the value of `usePasswordFiles` to false

If you wish to use a more recent version, simply set the option `usePasswordFiles: false` in the `postgresql` section of our chart's `values.yaml` file:

```yaml
    # Other values in our values.yaml 
     
    postgresql:
      auth:
        # Keep other values...
        usePasswordFiles: false
      # Keep other values...
```

Hopefully, this will help those facing any issues with using more recent versions of the PostgreSQL chart!

**⚠️ IMPORTANT II! Breaking Changes to Bitnami Charts and Images ⚠️**

This is a brief reminder regarding the latest breaking changes in Bitnami charts and Docker repositories. In case you are already midway through the course and didn't happen to see the announcement in earlier lectures, please take the time to go through the explanation in Lecture 18: IMPORTANT! Changes to Bitnami Charts and Images. This article will cover the necessary changes you need to implement so that the PostgreSQL dependency continues to work as in the lectures.
Uninstalling Broken Helm Charts

If you run into the `ErrImagePull` problem, make sure to first uninstall the existing Chart installation.

The commands you need to run are as follows:

```sh
helm uninstall config-store (or the name of your release)

kubectl delete pvc data-postgresql-db-0 
```

If the chart you have installed created other resources that are not removed when running the `helm uninstall` command, make sure to clean them up manually!

**Installing Helm Charts**

Below you will find a series of steps you can follow in case you start seeing Image Pull Errors when installing the Helm charts. After uninstalling the problematic Helm Chart by following the instructions from above, here are the steps you should follow:

1. In your `values.yaml` file, under the `postgresql` configuration key, add the instructions to point to the `bitnamilegacy` repository. It should look like the following:

```yaml
    postgresql:
      image:
        registry: docker.io
        repository: bitnamilegacy/postgresql
```

2. Make sure that the configuration is correct by confirming that the values.yaml file is correctly used (you can run `helm template <config-store path> | grep bitnamilegacy/postgresql`, for example). This should show the following `image: docker.io/bitnamilegacy/postgresql:17.2.0-debian-12-r0`. This will enable you to continue using the same chart versions from the lectures for the moment, and you should still be able to install the applications on your Kubernetes cluster.

### Add PostgreSQL subchart as chart dependency

### Passing values from parent to subchart

### Global values

### Including names templates from subchart in parent

### Conditionally enabling subcharts

### Integrate PostgreSQL into our Kubernetes resources

## Advanced Topics

### Accessing files

- [Github `accessing-files`](https://github.com/lm-academy/helm-course/tree/main/accessing-files)

### Chart hooks

- [Github `helm-hooks`](https://github.com/lm-academy/helm-course/tree/main/helm-hooks)

### Library charts

- [Github `helm-course/library-charts/parent-chart/`](https://github.com/lm-academy/helm-course/tree/main/library-charts/parent-chart)

### Test hook

return here on 84 class.

## Conclusion

## That's all

...folks
