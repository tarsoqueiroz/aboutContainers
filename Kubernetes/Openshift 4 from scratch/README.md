# Openshift 4 from scratch

## About

> [Udemy: Openshift 4 from scratch](https://www.udemy.com/course/openshift-4-from-scratch)

Learn how to deploy applications and manage all components of a Kubernetes cluster with Red Hat Openshift 4.

### What are you learn?

- Learn to deploy applications on Red Hat Openshift 4
- Fully upgraded to the latest versions
- Working with the components and resources of a Red Hat OpenShift cluster
- Using the WEB console to deploy and work with your applications
- Learn how to create and launch PODs and containers within OpenShift
- Learn how to create and work with Deployments
- Create and use services and routes
- Learn how to work with DeploymentConfig, BuildConfig, Routes and other Openshift resources.
- You will learn how to use the OC tool to work with the cluster.
- Learn how to manage images with ImageStreams
- Learn how to use S2I (Source to Image) to create applications from source code automatically.

## Introduction

- [Presentation](./resources/Presentation.pdf)
- [Openshift Architecture](./resources/Openshift_architecture.pdf)

## Options to do the course practices

- [Local tools 2023](./resources/local+tools+2023.pdf)

## CodeReady Containers (CRC): Working locally with Openshift 4

- [`https://okd.io/`](https://okd.io/)
- [`https://crc.dev/blog/`](https://crc.dev/blog/)
- [Introducing CRC](https://crc.dev/docs/introducing/)

## WEB console and `oc` tool

## Projects

```sh
oc get ns
oc get ns      | grep -v NAME | wc -l

oc get project
oc get project | grep -v NAME | wc -l

oc new-project tarsoproject
oc create ns   tarsons

oc get ns      | grep -ie tarso
oc get project | grep -ie tarso

oc get ns      -o wide | grep -ie tarso
oc get project -o wide | grep -ie tarso

oc new-project tarsons
oc create ns   tarsoproject

oc delete project tarsoproject
oc delete ns      tarsons

oc describe project vue-exemplo-hml

oc get project tarsodemo 
oc get project tarsodemo -o yaml
oc describe project tarsodemo 

kubectl create ns tarsons
oc describe project tarsons

oc get project vue-exemplo-hml -o yaml
```

- [Project manifest](./resources/project.yaml)

```sh
oc apply -f ./resources/project.yaml 

oc get project -l type=sample
oc get project -l kubernetes.io/metadata.name=tarsodemo

oc get project tarsodemo -o yaml
oc get project tarsoproject-hml -o yaml
```

## Kubernetes objects in an Openshift cluster

**IMPORTANT:** Configure permissions to avoid security errors

Hello, some images that we will use during the course require access privileges such as ROOT or need certain permissions to access volumes or ports.

For example postgres, redis, Apache, etc.

Although this course is not about Administration, we need to give certain permissions to the user so that they can work.

It is necessary to execute the following command in each of the projects that we create during the course

```sh
oc adm policy add-scc-to-user anyuid -z default
```

That way we can create objects and containers without problems.

**NOTE:** WHAT DO I DO IF I AM USING DEVELOPER SANDBOX OR MY OWN CLUSTER?

In the event that you cannot use CRC and therefore cannot change the permissions (for example if you are in Developer Sandbox), we have two possible options:

1. We can use some repositories other than Docker where there are images already prepared for Openshift.

The main repositories where we can find openshift images are:

- registration.redhat.io
- dock.io

You can search those repositories to find the one you need.

For example, if we want Apache (httpd in docker hub) we can use the following images:

- quay.io/fedora/httpd-24
- registry.access.redhat.com/rhscl/httpd-24-rhel7:2.4-220

2. We can use existing images within Openshift itself

In the "openshift" project we can find several internal images that we can use. For example, there is one from Apache (httpd).

To view these images we can use the command:

```sh
oc get is -n openshift
```

For example, the apache image is:

```sh
default-path-openshift-image-registry.apps.sandbox-m2.ll9k.p1.openshiftapps.com/openshift/httpd
```

In the following videos you will learn how to create PODs with images and you can use what you need

**Create a POD**:

```sh
oc projects
oc project tarsodemo 

oc get all 
oc get pod
oc describe pod devops-demo-app-git-557488dfc5-n9s5r 

oc run nginx1 --image=nginx

oc get pod

oc describe pod nginx1

oc get pod nginx1 -o yaml

oc rsh nginx1

oc exec -it nginx1 -- bash

## Create POD on WEB Console (click CREATE)

oc apply -f ./resources/nginx.yaml

oc get pod

## Create POD on WEB Console (click CREATE, copy nginx3.yaml)
```

## Deployments

- [Review Deployment](./resources/01-Intro+Deployments.pdf)

```sh
oc create deployment d1a --image=image-registry.openshift-image-registry.svc:5000/openshift/httpd:latest

## create by WEB Console

oc apply -f ./resources/deploy.yaml 

oc get deploy

oc get rs

oc get pod

oc get deployment apache1 -o wide --show-labels

oc label deploy apache1 responsible=tarso

oc get deployment apache1 -o wide --show-labels

oc get pods

oc scale deploy apache1 --replicas=5

oc get pods
```

## Services

- [Review Services](./resources/10-review+services.pdf)

```sh

oc get deployment apache1 

oc expose --name=apache1-svc deploy apache1 --type=NodePort

oc get svc

oc create deployment nginx-dep --image='image-registry.openshift-image-registry.svc:5000/openshift/httpd:latest'

oc get deploy

oc get pods -o wide --show-labels

## Service create by WEB Console

oc describe svc nginx-svc 

oc scale deploy nginx-dep --replicas=5

oc describe svc nginx-svc 

oc get pods -o wide
```

## Routes

- [Routes](./resources/10-routes.pdf)

```sh
oc get svc
oc expose svc nginx-svc 
oc get route
```

## DeploymentConfig

> **NOTE:** ***Deprecated from version 4.14***

- [DeploymentConfigs](./resources/01-DeploymentConfigs.pdf)

Openshift has declared the DeploymentConfig obsolete (Deprecated) since version 4.14.

Therefore, it is recommended to use Deployment instead.

Since they are still supported and may affect older installations or environments, I have decided to leave this object in progress for now.

But really, unless you have an older version at work, you should skip this section.

Any of the exercises or examples in the course where DeploymentConfig is used can be replaced by the Deployment, with hardly any changes.

## Application Deployment

- [Application Deployment](./resources/10-Application+deployments.pdf)

Since Openshift version 4.5 (which corresponds to CRC 1.13 or higher), the "new-app" command generates a Deployment instead of a DeploymentConfig.

If at any time you want to create a Deploymentconfig, it is necessary to indicate the following option when executing the command.

```sh
--as-deployment-config=true # with 2 dashes ahead
```

In any case, we will do an example throughout the course, although remember that Openshift recommends using Deployments, because Deploymentconfig are deprecated.

```sh
oc new-app apasoft/blog

oc new-app --name=nginx10 --as-deployment-config=true --image=nginx
```
