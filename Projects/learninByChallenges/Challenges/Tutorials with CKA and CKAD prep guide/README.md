# Kubernetes Tutorials with CKA and CKAD Prep Guide

## About

> [Kubernete Tutorials with CKA and CKAD Prep Guide](https://kubernetes-tutorial.schoolofdevops.com/)

Welcome to the Kubernetes Tutorial with CKA and CKAD Prep Guide by School of Devops

This document was originally created as a Lab Guide to go along with the [Kubernetes Course by School of Devops](http://www.schoolofdevops.com/). However, you could also use it on its own now to practice learning kubernetes topics.

If you still believe you could learn better and faster by audio visual means, definitely consider subscribing to our course at [schoolofdevops.com](http://schoolofdevops.com/).

Author: [Gourav Shah](https://www.linkedin.com/in/gouravshah)

## DOCKER ESSENTIALS FOR KUBERNETES

### Lab D101 - Operating Containers

```bash
## terminal 1
docker

docker version
docker -v
 
docker system info

## terminal 2
docker system events

## terminal 1
docker run alpine:3.4 uptime
docker container ps
docker container ps -l
docker ps -n 2
 
docker run -it alpine:3.4 sh
docker run -idt schoolofdevops/loop program
docker ps

docker container ps
docker container logs laughing_mirzakhani 
docker container logs -f laughing_mirzakhani 

docker container run -idt -P schoolofdevops/vote
docker ps -l
docker rename aef45e71308b vote
docker port vote
docker inspect vote
docker ps 
docker inspect vote

touch testfile
docker cp testfile vote:/home/.
docker exec -it vote sh

## terminal 3
docker stats --no-stream=true vote
docker stats

## terminal 1
docker update --memory 400M --memory-swap -1 vote

docker run -d --cpu-shares 1024 schoolofdevops/stresstest stress --cpu 2
docker run -d --cpu-shares 512 schoolofdevops/stresstest stress --cpu 2
docker run -d --cpu-shares 4096 schoolofdevops/stresstest stress --cpu 2
docker run -d --cpus 0.2 schoolofdevops/stresstest stress --cpu 2

docker system df
htop

docker container prune
docker system prune
docker container ps

docker stop loving_jackson 
docker kill brave_bose 
docker container ps
docker stop heuristic_mendeleev vigilant_allen 
docker kill zen_chatelet xenodochial_ride 

htop
docker ps -as
docker container prune
docker ps -as
docker system prune
docker ps -as

docker stop vote
docker kill laughing_mirzakhani 
docker ps -as

docker container prune
docker ps -as

htop
```

### Lab D102 - Building and Publishing Docker Images

Voteapp is a app written in python. Its a simple, web based application which serves as a frontend for Instavote project. As a devops engineer, you have been tasked with building an image for vote app and publish it to docker hub registry.

- [`https://github.com/schoolofdevops/vote`](https://github.com/schoolofdevops/vote)

```bash
git clone https://github.com/schoolofdevops/vote
cd vote
rm -rf .git
cd ..

docker container run -idt --name dev -p 8000:80 python:alpine3.17 sh

cd vote
docker cp . dev:/app
docker exec -it dev sh

## inside the container

cd /app
pip install -r requirements.txt
gunicorn app:app -b 0.0.0.0:80
## validate by accessing http://IPADDRESS:8000

## on the host
docker diff dev

docker container commit dev docker.io/<username>/vote:v1

docker login

docker image push docker.io/<username>/vote:v1

cd vote
ls

app.py  requirements.txt  static  templates
```

- `Dockerfile.yaml`

```dockerfile
FROM python:alpine3.17

WORKDIR /app

COPY . .

RUN pip install -r requirements.txt

EXPOSE 80

CMD  gunicorn app:app -b 0.0.0.0:80
```

```bash
docker build -t docker.io/<username>/vote:v2 .

docker image ls
docker image history docker.io/<username>/vote:v2
docker image history docker.io/<username>/vote:v1

docker container run -idt -P docker.io/<username>/vote:v2
docker ps

docker image tag docker.io/<username>/vote:v2 docker.io/<username>/vote:latest
docker login
docker push docker.io/<username>/vote
docker push docker.io/<username>/vote:v2
```

### Lab D103 - Docker Networking

```bash
docker network ls

docker network create -d bridge mynet

docker network ls

docker network inspect mynet

docker container run -idt --name nt01 alpine sh
docker container run -idt --name nt02 alpine sh

docker container run -idt --name nt03 --net mynet alpine sh
docker container run -idt --name nt04 --net mynet alpine sh

docker exec nt01 ifconfig eth0
docker exec nt02 ifconfig eth0
docker exec nt03 ifconfig eth0
docker exec nt04 ifconfig eth0

[replace ip addresses as per your setup]
docker exec nt01  ping 172.17.0.19
docker exec nt01  ping 172.18.0.2

docker exec nt03  ping 172.17.0.19
docker exec nt03  ping 172.18.0.2

docker container run -idt --name nt05 --net none alpine sh

docker exec -it nt05 sh

ifconfig

docker container run -idt --name nt05 --net host  alpine sh

docker exec -it nt05 sh

ifconfig

docker run -it --net host --privileged  nicolaka/netshoot


iptables -nvL -t nat

brctl show

ip route show
```

### Lab D104 - Docker Volumes

```bash
docker container run  -idt --name vt01 -v /var/lib/mysql  alpine sh
docker inspect vt01 | grep -i mounts -A 10

docker container run  -idt --name vt02 -v db-data:/var/lib/mysql  alpine sh
docker inspect vt02 | grep -i mounts -A 10

mkdir /root/sysfoo
docker container run  -idt --name vt03 -v /root/sysfoo:/var/lib/mysql  alpine sh
docker inspect vt03 | grep -i mounts -A 10

ls /root/sysfoo/
touch /root/sysfoo/file1
docker exec -it vt03 sh
ls sysfoo/
```

## KUBERNETES ESSENTIALS

### Lab K101 - Install Kubernetes with KIND

### Lab K102 - Kubernetes Quickdive

### Lab K103 - Pods

### Lab K104 - Namespaces and ReplicaSets

### Lab K105 - Service Networking

### Lab K107 - Deployments

### Lab K108 - Storage

### Lab K109 - Mini Project

### Lab K110 - ConfigMaps & Secrets

### Lab K112 - Ingress

### Lab K113 - Setup Prometheus and Grafana with HELM

### Lab K114 - Adding Log Monitoring with Loki

### Lab K115 - Writing HELM Charts

### Lab K116 - Publishing HELM Charts

## ADVANCED KUBERNETES

### Lab K801 - Setting up Kubernetes Cluster

### Lab K802 - Exploring Kubernetes Control Plane

### Lab K803 - Service Networking and Kube Proxy

### Lab K803 - Setting up Cilium CNI with KIND

### Lab K804 - Exploring Cilium

### Lab K805 - Controllers and CRDs

### Lab K806 - Operators

### Lab K807 - Writing Custom Operator in Go

### Lab K807 - Launch EKS Cluster

### Lab K808 - Horizontal and Vertical Autoscaling

### Lab K809 - Service Mesh with Istio

## ADDITIONAL CKAD TOPICS

Lab K201 - Advanced Pod Design
Lab K204 - Health Checks
Lab K205 - DaemonsSets & CronJobs
Lab K206 - Statefulsets

ADDITIONAL CKA TOPICS

Lab K301 - Auto Scaling with HPA
Lab K302 - Autoscaling on Custom Metric
Lab K303 - Advanced Pod Scheduling
Lab K304 - Cluster Administration
Lab K305 - Cluster Troubleshooting

KUBERNETES SECURITY

Lab K111 - RBAC Policies
Lab K207 - Network Policies

ADDITIONAL TOPICS

Lab K400 - Install Kubernetes with Kubeadm
Lab K401 - Creating Users, Groups and Authorization
Lab K403 - Building Deployment Strategies
Lab K404 - CNI
Lab K404 - Kubernetes Operators
Troubleshooting Tips
Logging

AWS AND KUBERNETES

Lab K405 - AWS Controller for Kubernetes

AWS EKS

Lab K501 - EKS Preparatory Setup
Lab K502 - EKS Setup
Lab K503 - Deploy Apps on EKS
Lab K504 - Ingress with ALB
Lab K505 - Persistent Storage with EBS
Lab K506 - IRSA
Lab K507 - EKS Cluster Autoscaler
Lab K509 - Horizontal Pod Autoscaler
Lab K510 - Verticle Pod Autoscaler
Lab K511 - EKS Monitoring
Lab K512 - EKS Costs
Lab K599 - EKS Cleanup

ARGO

Lab K101 - Install Kubernetes with KIND
Lab K602 - Blue/Green with Argo Rollouts
Lab K603 - Canary with Argo Rollouts
Lab K604 - ArgoCD
Lab K605 - Argo Workflow Examples
Lab K606 - CI Pipeline with Argo Workflows
Lab K607 - Argo Events
Lab K608 - Argo Image Updater
Lab K609 - Experiments and Analysis

ARGO ARTICLES

ArgoCD Advanced Sync Strategies
ArgoCD Resource Lifecycle Management
ArgoCD Sync Options
ArgoCD - Server Side Apply
ArgoCD - RETRY Options
ArgoCD - Prune Propogation Policy
GitHub Actions Code Explainer
Lua Scripting in Argo

ARGO ADVANCED

Lab K701 - Setup CI/CD with GHA and Argo
Lab K702 - Building Multi-Tenant Deployment System
Lab K703 - Advanced Sync Strategies
Lab K704 - Experiments and Analysis
Lab K704 - Kargo
Lab K705 - TBA

EXERCISES

XER001 - Pods
XER002 - ReplicaSets
XER003 - Deploy Instavote Stack

WEB QUESTS

KWQ001 - CNI Web Quest
KWQ001 - Kubernetes Security Web Quest
KWQ003 - Ingress Web Quest
KWQ004 - Monitoring Web Quest
KWQ005 - Controllers Web Quest
KWQ006 - Persistent Data Web Quest
KWQ007 - Cluster Maintenance Web Quest

REFERENCES

RBAC apiGroups to Resource Mapping
