# IntroDuction to Cilium (LFS146)

## About

When you deploy Kubernetes, you need to install a networking plug-in implementing the Container Networking Interface (CNI) to provide connectivity between workloads. Cilium is a popular and widely-deployed CNI solution that is now the default across many Kubernetes distributions and cloud provider offerings.

In this course, you will learn the basics of Cilium and how it can be used to connect, observe, and secure Kubernetes clusters. We will start by reviewing the container networking challenges motivating the creation of Cilium, we’ll move on to discussing the architecture of Cilium and how it uses eBPF – a revolutionary Linux kernel technology – to address those challenges.

> [`https://trainingportal.linuxfoundation.org/learn/course/introduction-to-cilium-lfs146`](https://trainingportal.linuxfoundation.org/learn/course/introduction-to-cilium-lfs146)

## Cilium Overview

[Cilium](https://cilium.io/) is an open source, cloud native solution for providing, securing, and observing network connectivity between workloads. In this course, we'll focus on learning how to use Cilium in Kubernetes environments where the aforementioned workloads are Kubernetes pods. However, it's important to point out that the benefits of Cilium aren't limited to Kubernetes environments.

In a Kubernetes environment, Cilium acts as a networking plugin that provides connectivity between pods. It provides security by enforcing network policies and through transparent encryption, and the Hubble component of Cilium provides deep visibility into network traffic flows.

Thanks to [eBPF](https://ebpf.io/what-is-ebpf/), Cilium’s networking, security, and observability logic can be programmed directly into the kernel, making Cilium and Hubble’s capabilities entirely transparent to application workloads. These will be containerized workloads in a Kubernetes cluster, though Cilium can also connect traditional workloads such as virtual machines and standard Linux processes.

## Kubernetes Kind

- [`kind-config.yaml`](./kind-config.yaml)

```bash
kind create cluster --config=./kind-config.yaml --name lfs146-cilium

kubectl config current-context

kubectl get nodes
```

## Install Cilium

Install Cilio CLI:

```bash
# Download Cilium CLI
curl -L --remote-name-all https://github.com/cilium/cilium-cli/releases/latest/download/cilium-linux-amd64.tar.gz{,.sha256sum}
# Verify the download
sha256sum --check cilium-linux-amd64.tar.gz.sha256sum
# Extract Cilium CLI
sudo tar xzvfC cilium-linux-amd64.tar.gz /usr/local/bin
# Clean up
rm cilium-linux-amd64.tar.gz{,.sha256sum}
```

Completion for Cilio:

```bash
# Cilium CLI completion
cilium completion bash | sudo tee /etc/bash_completion.d/cilium_completion
```

Verify CLI install:

```bash
# Cilium CLI version
cilium version
```

Install Cilium on Kubernetes (Kind):

```bash
# Show me the clusters
kind get clusters
# Show me the nodes status
kubectl get nodes

# Install Cilium
cilium install
# Validate the installation
cilium status --wait

# Enable Hubble UI
cilium hubble enable --ui
# Verify Hubble installation
cilium status --wait

# Validate the network connectivity
cilium connectivity test --request-timeout 30s --connect-timeout 10s
```

Examine cluster with `kubectl`:

```bash
# Show me the nodes status
kubectl get nodes

kubectl get daemonsets --all-namespaces

kubectl get deployments --all-namespaces
```

## Network Policy

### Prerequisites for Network Policy

- You’ll need a Kubernetes cluster with Cilium installed.
- You’ll also need to deploy a Death Star application, including the service definition, service backend pods, and pods acting as TIE fighter clients that access the service using internal-only cluster communications. The Cilium project has an example [Death Star demo application](https://docs.cilium.io/en/latest/gettingstarted/demo/#deploy-the-demo-application) manifest you can use.

```bash
# Deploy the Death Star demo application
kubectl create -f https://raw.githubusercontent.com/cilium/cilium/HEAD/examples/minikube/http-sw-app.yaml

# Verify the Death Star application is running
kubectl get services

# Cilium Endpoint has been created for each pod that was added
kubectl get pods,CiliumEndpoints

# Time to make some landing requests for both the TIEs and the X-wings
kubectl exec xwing -- curl -s -XPOST deathstar.default.svc.cluster.local/v1/request-landing
kubectl exec tiefighter -- curl -s -XPOST deathstar.default.svc.cluster.local/v1/request-landing

```

### Empire ingress allow policy

We can craft this policy using the networkpolicy.io policy editor:

- [Network Policy Editor](https://editor.networkpolicy.io/)

> The service map in the policy editor should now indicate that only ingress from pods labeled org=empire in the same namespace as the Death Star service will be able to access TCP port 80 on the corresponding deathstar endpoints.

- [`allow-empire-in-namespace-v1.yaml`](./allow-empire-in-namespace-v1.yaml)

```bash
# Test after the policy is applied: both OK
kubectl exec xwing -- curl --connect-timeout 10 -s -XPOST deathstar.default.svc.cluster.local/v1/request-landing
kubectl exec tiefighter -- curl --connect-timeout 10 -s -XPOST deathstar.default.svc.cluster.local/v1/request-landing

# Deploy the network policy
kubectl apply -f ./allow-empire-in-namespace.yaml

# Test before the policy is applied: xwing nOK and tiefighter OK
kubectl exec xwing -- curl --connect-timeout 10 -s -XPOST deathstar.default.svc.cluster.local/v1/request-landing
kubectl exec tiefighter -- curl --connect-timeout 10 -s -XPOST deathstar.default.svc.cluster.local/v1/request-landing
```

ERROR: policy that limits access even further:

```bash
kubectl exec tiefighter -- curl -s -XPUT deathstar.default.svc.cluster.local/v1/exhaust-port
```

But we can fix that with L7 HTTP policy that limits access even further, so the exhaust-port API endpoint is only available to Imperial maintenance droids and not hotshot rookie pilots who can’t tell a landing bay from an exhaust port. We can address the design flaws in the API’s exhaust-port endpoint in our next development sprint (why does the API even need an exhaust port?), but for now let’s use the CiliumNetworkPolicy Custom Resource Definition to restrict access so it doesn’t happen again.

### L7 HTTP path specific allow policy

Let’s extend the empire access policy to include the rules for landing path and exhaust port paths explicitly:

- [`allow-empire-in-namespace-v2.yaml`](./allow-empire-in-namespace-v2.yaml)

```bash
# Deploy the network policy with the new rules
kubectl apply -f ./allow-empire-in-namespace-v2.yaml
# Try again with the exhaust port
kubectl exec tiefighter -- curl -v -s -XPUT deathstar.default.svc.cluster.local/v1/exhaust-port
```

We’ve successfully limited access to the Death Star API so TIE fighters can make landing requests, without giving them access to the exhaust port. And we’ve kept any X-wings in the cluster from accessing the Death Star API at all. Lord Vader will be pleased.

## Network Observability using Hubble

### Hubble

Hubble is a fully distributed networking observability platform. It is built on top of Cilium and eBPF to enable deep visibility into the communication and behavior of services, as well as the networking infrastructure in a completely transparent manner.

### Prerequisites for Hubble

This lab assumes you have completed the labs from Chapter 3 & 4. You should have the following:

- A Cilium-managed Kubernetes cluster with Hubble components enabled.
- The Cilium CLI tool installed into your local workstation environment.
- The Death Star demo application deployed in the default namespace, with a CiliumNetworkPolicy resource defined to limit internal cluster access to the Death Star service.

### Install the Hubble Client

- [Install client](https://docs.cilium.io/en/stable/observability/hubble/setup/index.html#install-the-hubble-client)

```bash
HUBBLE_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/hubble/master/stable.txt)
HUBBLE_ARCH=amd64

if [ "$(uname -m)" = "aarch64" ]; then HUBBLE_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/hubble/releases/download/$HUBBLE_VERSION/hubble-linux-${HUBBLE_ARCH}.tar.gz{,.sha256sum}
sha256sum --check hubble-linux-${HUBBLE_ARCH}.tar.gz.sha256sum
sudo tar xzvfC hubble-linux-${HUBBLE_ARCH}.tar.gz /usr/local/bin
rm hubble-linux-${HUBBLE_ARCH}.tar.gz{,.sha256sum}

hubble version
```

## Prometheus Metrics

Cilium and Hubble can both be configured to serve Prometheus metrics. Moreover, Cilium and Hubble metrics can be enabled independently of each other to give you granular control. Broadly speaking, Cilium metrics show how Cilium’s components are operating, while Hubble metrics provide information about network flows and network performance.

In this chapter, we’ll review the metrics Cilium and Hubble are able to provide, and then get hands-on enabling metrics collection in our cluster. The Cilium project documentation has the [full details](https://docs.cilium.io/en/stable/observability/metrics/) for configuring metrics collection.

```bash
kind create cluster --name cilium --config ./kind-config.yaml

kubectl cluster-info
kubectl get nodes

helm install cilium cilium/cilium --version 1.16.3 --set prometheus.enabled=true --set operator.prometheus.enabled=true --namespace kube-system

kubectl get nodes 
kubectl get pods -A

cilium status

cilium hubble enable
cilium status

kubectl apply -f https://raw.githubusercontent.com/cilium/cilium/refs/heads/main/examples/minikube/http-sw-app.yaml

kubectl apply -f https://raw.githubusercontent.com/cilium/cilium/refs/heads/main/examples/minikube/sw_l3_l4_l7_policy.yaml

kubectl get pods -A
cilium status
```

## Replacing Kube-Proxy

We’ll need to start with a Kubernetes cluster created without kube-proxy installed for this lab.

- [`kind-config-nokp.yaml`](./kind-config-nokp.yaml)

```bash
kind create cluster --config=./kind-config-nokp.yaml --name lfs146-cilium-nokp

kubectl config current-context

kubectl get nodes
```

Now let’s confirm the cluster does not have kube-proxy installed:

```bash
kubectl get -A daemonsets
kubectl get -A daemonsets | grep kube-proxy
kubectl get -A pods
kubectl get -A pods | grep kube-proxy
kubectl get -A configmaps
kubectl get -A configmaps | grep kube-proxy
```

Install Cilium with kube-proxy:

```bash
cilium install

🔮 Auto-detected Kubernetes kind: kind
ℹ️  Using Cilium version 1.16.6
🔮 Auto-detected cluster name: kind-lfs146-cilium-nokp
ℹ️  Detecting real Kubernetes API server addr and port on Kind
🔮 Auto-detected kube-proxy has not been installed
ℹ️  Cilium will fully replace all functionalities of kube-proxy
```

o validate the kube-proxy replacement is working, we can use the Cilium CLI tool and have it run the complete set of connectivity tests now, and we should see NodePort services being created for testing:

```bash
cilium connectivity test --connect-timeout 30s --request-timeout 30s
```

Alternatively, we can manually test the NodePort connectivity:

- [`nokp-nginx.yaml`](./nokp-nginx.yaml)

```bash
kubectl apply -f nokp-nginx.yaml

kubectl get pods -l run=nokp-nginx -o wide
```

NodePort service for the nginx pod:

```bash
## expose a deployment
kubectl expose deployment nokp-nginx --type=NodePort --port=80

## verify the service
kubectl get svc nokp-nginx

## validating by Cilium client's service list
kubectl -n kube-system exec ds/cilium -- cilium service list
```

## Transparent Encryption

