# TechWorld with Nana: Kubernetes Tutorial for Beginners

FULL COURSE in 4 Hours

> ```https://www.youtube.com/watch?v=X48VuDVv0do```

em https://www.youtube.com/watch?v=X48VuDVv0do estou em 0:00

## 1 (0:00) - Course Overview (Day 1)

## 2 (2:18) - What is K8s

🔥  What is Kubernetes 🔥 

### What problems does Kubernetes solve?

### What features do container orchestration tools offer?

## 3 (5:20) - Main K8s Components

🔥  Main K8s Components 🔥  

### Node & Pod

### Service & Ingress

### ConfigMap & Secret

### Volumes

### Deployment & StatefulSet

## 4 (22:29) - K8s Architecture

🔥  K8s Architecture 🔥

### Worker Nodes

### Master Nodes

### Api Server

### Scheduler

### Controller Manager

### etcd - the cluster brain

## 5 (34:47) - Minikube and kubectl - Local Setup

🔥  Minikube and kubectl - Local Setup 🔥

### 🔗 Links

- Install Minikube (Mac, Linux and Windows): https://bit.ly/38bLcJy 
- Install Kubectl: https://bit.ly/32bSI2Z
- Gitlab: If you are using Mac, you can follow along the commands. I listed them all here: https://bit.ly/3oZzuHY

### What is minikube?

### What is kubectl?

### Install minikube and kubectl

### Create and start a minikube cluster

## 6 (44:52) - Main Kubectl Commands - K8s CLI (Day 2)

🔥  Main Kubectl Commands - K8s CLI 🔥

### 🔗 Links

- Git repo link of all the commands: https://bit.ly/3oZzuHY

### Get status of different components

### create a pod/deployment

### layers of abstraction

### change the pod/deployment

### debugging pods

### delete pod/deployment

### CRUD by applying configuration file

## 7 (1:02:03) - K8s YAML Configuration File

🔥  K8s YAML Configuration File 🔥

### 🔗 Links

- Git repo link: https://bit.ly/2JBVyIk

### 3 parts of a Kubernetes config file (metadata, specification, status)

### format of configuration file

### blueprint for pods (template)

### connecting services to deployments and pods (label & selector & port)

### demo

## 8 (1:16:16) - Demo Project: MongoDB and MongoExpress

🔥 Demo Project 🔥

### 🔗 Links

- Git repo link: https://bit.ly/3jY6lJp

### Deploying MongoDB and Mongo Express

### MongoDB Pod

### Secret

### MongoDB Internal Service

### Deployment Service and Config Map

### Mongo Express External Service

## 9 (1:46:16) - Organizing your components with K8s Namespaces (Day 3)

🔥  Organizing your components with K8s Namespaces 🔥

### 🔗 Links

- Install Kubectx: https://github.com/ahmetb/kubectx#installation

### What is a Namespace?

### 4 Default Namespaces

### Create a Namespace

### Why to use Namespaces? 4 Use Cases

### Characteristics of Namespaces

### Create Components in Namespaces

### Change Active Namespace

## 10 (2:01:52) - K8s Ingress explained

🔥  K8s Ingress explained 🔥

### 🔗 Links

- Git Repo: https://bit.ly/3mJHVFc
- Ingress Controllers: https://bit.ly/32dfHe3
- Ingress Controller Bare Metal: https://bit.ly/3kYdmLB

### What is Ingress? External Service vs. Ingress

### Example YAML Config Files for External Service and Ingress

### Internal Service Configuration for Ingress

### How to configure Ingress in your cluster?

### What is Ingress Controller?

### Environment on which your cluster is running (Cloud provider or bare metal)

### Demo: Configure Ingress in Minikube

### Ingress Default Backend

### Routing Use Cases

### Configuring TLS Certificate

## 11 (2:24:17) - Helm - Package Manager (Day 4)

🔥  Helm - Package Manager 🔥

### 🔗 Links

- Helm hub: https://hub.helm.sh/
- Helm charts GitHub Project: https://github.com/helm/charts
- Install Helm: https://helm.sh/docs/intro/install/

### Package Manager and Helm Charts

### Templating Engine

### Use Cases for Helm

### Helm Chart Structure

### Values injection into template files

### Release Management / Tiller (Helm Version 2!)

## 12 (2:38:07) - Persisting Data in K8s with Volumes

🔥  Persisting Data in K8s with Volumes 🔥

### 🔗 Links

- Git Repo: https://bit.ly/2Gv3eLi

### The need for persistent storage & storage requirements

### Persistent Volume (PV)

### Local vs Remote Volume Types

### Who creates the PV and when?

### Persistent Volume Claim (PVC)

### Levels of volume abstractions

### ConfigMap and Secret as volume types

### Storage Class (SC)

## 13 (2:58:38) - Deploying Stateful Apps with StatefulSet (Day 5)

🔥  Deploying Stateful Apps with StatefulSet 🔥

### What is StatefulSet? Difference of stateless and stateful applications

### Deployment of stateful and stateless apps

### Deployment vs StatefulSet

### Pod Identity

### Scaling database applications: Master and Worker Pods

### Pod state, Pod Identifier

### 2 Pod endpoints

## 14 (3:13:43) - K8s Services explained

🔥  K8s Services 🔥

### What is a Service in K8s and when we need it?

### ClusterIP Services

### Service Communication

### Multi-Port Services

### Headless Services

### NodePort Services

### LoadBalancer Services

## That's all folks!!!
___
