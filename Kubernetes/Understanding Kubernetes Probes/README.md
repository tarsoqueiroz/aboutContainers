# Understanding Kubernetes Probes By Deploying A Go App

## About

> [`https://dev.to/olymahmud/understanding-kubernetes-probes-by-deploying-a-go-app-716`](https://dev.to/olymahmud/understanding-kubernetes-probes-by-deploying-a-go-app-716)

## What Are Kubernetes Probes?

Kubernetes probes are diagnostic mechanisms that assess the health and readiness of containers within a cluster. They function as automated health checks, ensuring that your application remains operational, is prepared to handle traffic, and starts correctly. The three primary types of probes are:

- **Liveness Probe:** Verifies if the container is running and responsive. If it fails, Kubernetes restarts the container to recover it.
- **Readiness Probe:** Confirms if the container is ready to accept traffic. If it fails, Kubernetes stops routing traffic to the container until it is ready.
- **Startup Probe:** Ensures the application has sufficient time to initialize before other probes begin, which is essential for applications with longer startup times.

These probes serve as critical safeguards, preventing failures and ensuring seamless operation.

## Why Do We Use Kubernetes Probes?

Probes are indispensable because they provide Kubernetes with visibility into application status, enabling automated responses to issues. Key reasons include:

- **Maintain Application Health:** Liveness probes detect and address unresponsive states by restarting containers, minimizing downtime.
- **Manage Traffic Efficiently:** Readiness probes ensure traffic is only directed to fully operational containers, enhancing user experience.
- **Facilitate Smooth Startups:** Startup probes allow applications time to initialize without being prematurely flagged as unhealthy.
- **Enable Self-Healing:** Probes allow Kubernetes to automatically recover or reschedule containers, reducing manual intervention.

In essence, probes enhance the reliability, scalability, and efficiency of Kubernetes deployments.

## Probes in Action: A Simple Project

View this part on app sample in [Github:aboutGo: Understanding Kubernetes Probes By Deploying A Go App](https://github.com/tarsoqueiroz/aboutGo/tree/main/Projects/Kubernetes/k8sProbes).

## Deploying to Kubernetes

Kubernetes deployment YAML file: [`deployment.yaml`](./deployment.yaml)

Probes Explanation:

- Liveness Probe:
  - **httpGet.path:** /healthz: Checks the /healthz endpoint to confirm the container is alive.
  - **httpGet.port: 8080:** Targets port 8080 for the HTTP request.
  - **initialDelaySeconds: 15:** Delays the first check by 15 seconds to allow startup.
  - **periodSeconds: 10:** Performs checks every 10 seconds.
  - **failureThreshold: 3:** Triggers a restart if the probe fails 3 consecutive times.
- Readiness Probe:
  - **httpGet.path: /readyz:** Verifies readiness via the /readyz endpoint.
  - **httpGet.port: 8080:** Uses port 8080.
  - **initialDelaySeconds: 5:** Begins checking 5 seconds after startup.
  - **periodSeconds: 5:** Checks every 5 seconds.
  - **failureThreshold: 3:** Halts traffic if it fails 3 times until ready.
- Startup Probe:
  - **httpGet.path: /:** Ensures startup success by checking the root path.
  - **httpGet.port: 8080**: Targets port 8080.
  - **initialDelaySeconds: 5:** Starts after 5 seconds.
  - **periodSeconds: 5:** Checks every 5 seconds during startup.
  - **failureThreshold: 30:** Permits up to 30 failures before declaring startup failure, accommodating longer initialization.

Kubernetes service YAML file: [`service.yaml`](./service.yaml)
