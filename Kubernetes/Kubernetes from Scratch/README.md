# Mastering Kubernetes From Scratch (Hands-On)

## About

> [Udemy: Mastering Kubernetes From Scratch (Hands-On)](https://www.udemy.com/course/kubernetes-cloud-native)

**Cloud Native Application Development Series**

This comprehensive course is designed for senior and staff-level engineers who want to elevate their Kubernetes expertise and confidently apply it to real-world production scenarios. Through a combination of in-depth lectures and hands-on exercises, you will gain a masterful understanding of core Kubernetes concepts and develop the practical skills needed to:

- Design and deploy highly scalable and resilient applications.
- Optimize resource utilization and manage production clusters efficiently.
- Implement automated deployments and rollbacks for streamlined workflows.
- Ensure application high availability and robust monitoring.
- Leverage cloud platforms like Google Cloud Platform for seamless Kubernetes deployment and management.

Boost Your Career in the Booming Field of Container Orchestration:

Mastering Kubernetes is a significant asset in today's IT landscape. This course empowers you to:

- Become a valuable asset to your team and organization.
- Stay ahead of the curve in the rapidly evolving field of containerization.
- Command a higher salary in the high-demand Kubernetes job market.

Course Curriculum:

- Kubernetes Architecture: Deep dive into the core components and their roles (api-server, etcd, controller, scheduler).
- Hands-on Cluster Creation: Learn to create Kubernetes clusters using tools like kind.
- Pod Management: Explore deploying workloads, accessing logs, containers, APIs, and debugging techniques.
- Deployment Strategies: Master managing application revisions, rollbacks, and implementing different deployment strategies.
- Service Discovery and Load Balancing: Understand different service types (ClusterIP, NodePort, LoadBalancer).
- Resource Management with Namespaces: Learn to logically separate workloads and resources.
- Health Monitoring and Liveness/Readiness Probes: Implement strategies for application health checks and monitoring.
- Configuration Management with ConfigMaps and Secrets: Discover secure ways to manage configurations and secrets.
- Stateful Applications with Persistent Volumes and StatefulSets: Utilize persistent storage for stateful applications and explore running MongoDB in Kubernetes.
- Dynamic Scaling with Horizontal Pod Autoscaler: Scale applications based on CPU and memory metrics.
- Efficient Traffic Management with Ingress: Create routing rules for efficient traffic management.
- Kubernetes on Cloud Platform (Google Kubernetes Engine / GKE): Explore deploying and managing clusters on a cloud platform.

Enroll Now and Master Kubernetes for Production!

Take the next step in your Kubernetes journey and unlock its power to build, deploy, and manage your applications with confidence. This course provides the hands-on experience and in-depth knowledge you need to become a Kubernetes powerhouse in your production environment.

Who's this course for:

- Software engineers who want to understand Kubernetes deeply
- Developers who want to deploy applications to Kubernetes
- DevOps and platform engineers who want hands on experience

## Introduction

Course Materials:

Please find the resources which might be helpful for you.

- The Source Code for this course is available here: [Github: kubernetes-course](https://github.com/vinsguru/kubernetes-course).
- Kubernetes commands we discuss in this course is here: [PDF k8s-commands](./resources/k8s-commands.pdf).

## Kubernetes Clusters

- Kubernetes cluster components: k8s-commands page 2
- [Kubernetes Documentation](https://kubernetes.io/docs/home/)

Tools:

- kubectl
- kind

Starting with Kind K8s cluster:

```sh
kind create cluster --config ./resources/Github-kubernetes-course/sec01-cluster-creation/01-cluster.yaml  -n k8sfromscratch
kubectl cluster-info 
kubectl get nodes -o wide
kubectl version --output=yaml
docker ps -as
docker exec -it k8sfromscratch-control-plane bash
```

Inside Control Pane container:

```sh
ls -alhF
cd /etc/kubernetes/manifests/
ls -alhF
ps -aux
exit
```

Go to worker container:

```sh
docker ps -as
docker exec -it k8sfromscratch-worker bash
```

Inside Worker container:

```sh
ls -alhF
ps -aux
exit
```

Clear cluster:

```sh
kind delete cluster -n k8sfromscratch
docker ps -as
kubectl version --output=yaml
```

## Pod

```sh
## Create K8s ckyster
kind create cluster --config ./manifests/0101-cluster.yaml 
kubectl get nodes -o wide

## create first pod
kubectl get pod

## terminal alternative
watch -t -x kubectl get pod
kubectl create -f ./manifests/0201-simple-pod.yaml 
kubectl get pod

## delete first pod
kubectl delete -f ./manifests/0201-simple-pod.yaml 
kubectl get pod

## describe a pod
kubectl create -f ./manifests/0201-simple-pod.yaml 
kubectl describe pod

## 
```
