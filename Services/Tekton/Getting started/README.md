# Tekton - Getting started

## About

- [Tekton: Getting started](https://tekton.dev/docs/getting-started/)
- [Tekton by Google Cloud](https://cloud.google.com/tekton)

Tekton is an open-source cloud native CICD (Continuous Integration and Continuous Delivery/Deployment) solution. Check the [Concepts section](https://tekton.dev/docs/concepts/) to learn more about how Tekton works.

Let’s get started! You can go ahead and [**create your first task with Tekton**](https://tekton.dev/docs/getting-started/tasks/). If you prefer, watch the following videos to learn the basics of how Tekton works before your first hands-on experience.

## Cluster K8s (KinD)

```sh
# Create cluster
kind create cluster --config ClusterConf.yaml
# Verifying
kubectl cluster-info --context kind-kluster
kubectl get nodes -o wide
```

## Install Tekton Pipelines

```sh
# Apply latest version of Tekton pipelines
kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
# Monitor the installation
kubectl get pods --namespace tekton-pipelines --watch
```

## Create and run a basic Task

```sh
# Task in hello-world.yaml
# Apply task
kubectl apply --filename hello-world.yaml

# TaskRun in hello-world-run.yaml
# Apply taskRun to instantiate and execute the object
kubectl apply -f ./tasks/hello-world-run.yaml
# Verify that everything worked
kubectl get taskrun hello-task-run 
kubectl describe taskruns.tekton.dev hello-task-run 
kubectl get taskrun hello-task-run
# Take a look at the logs
kubectl logs --selector=tekton.dev/taskRun=hello-task-run
```

## Install the Tekton CLI

Get link of relase package on the [Releases page](https://github.com/tektoncd/cli/releases):

```sh
curl -LO <LINK-TO-THE-PACKAGE>
sudo dpkg -i ./<PACKAGE-NAME>
```

## Create and run a second Task

```sh
# Second task in goodbye-world.yaml
# Apply the Task file
kubectl apply -f ./tasks/goodbye-world.yaml
```

## Create and run a Pipeline

```sh
# Pipeline in hello-goodbye-pipeline.yaml
# Apply the pipeline file
kubectl apply -f tasks/hello-goodbye-pipeline.yaml
# PipelineRun in hello-goodbye-pipeline-run.yaml
# Apply the PipelineRun
kubectl apply -f tasks/hello-goodbye-pipeline-run.yaml
# To see the logs of the PipelineRun
tkn pipelinerun logs hello-goodbye-run -f -n default
```

## Install Tekton Triggers

```sh
# Install Tekton Triggers
kubectl apply --filename https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml
kubectl apply --filename https://storage.googleapis.com/tekton-releases/triggers/latest/interceptors.yaml
# Monitor the installation
kubectl get pods --namespace tekton-pipelines --watch
```

## Create a TriggerTemplate

```sh
# TriggerTemplate in trigger-template.yaml
# Apply manifest
kubectl apply -f tasks/trigger-template.yaml
```

## Create a TriggerBinding

```sh
# TriggerBinding in trigger-binding.yaml
# Apply the TriggerBinding
kubectl apply -f tasks/trigger-binding.yaml
```

## Create an EventListener

```sh
# EventListener in event-listener.yaml
# Service account in 
# Apply RBAC
kubectl apply -f tasks/rbac.yaml
```

## Running the Trigger

```sh
# Create the EventListener
kubectl apply -f tasks/event-listener.yaml
# To communicate outside the cluster, enable port-forwarding
kubectl port-forward services/el-hello-listener 8080
```

## Monitor the Trigger

```sh
# Send an event
curl -v -H 'content-Type: application/json' -d '{"username": "Tekton"}' http://localhost:8080
# Check the PipelineRuns on cluster
kubectl get pipelineruns.tekton.dev --watch
# Check the PipelineRun logs
tkn pipelinerun logs hello-goodbye-run-rqscs -f

# Send a second event
curl -v -H 'content-Type: application/json' -d '{"username": "Teste1"}' http://localhost:8080
# Check the PipelineRuns on cluster
kubectl get pipelineruns.tekton.dev --watch
# Check the PipelineRun logs
tkn pipelinerun logs hello-goodbye-run-6j5c6 -f
```

## Install Tekton Chains

```sh
# Install Tekton Chains
kubectl apply --filename https://storage.googleapis.com/tekton-releases/chains/latest/release.yaml
# Monitor the installation
kubectl get pods --namespace tekton-chains --watch

# Configure Tekton Chains to store the provenance metadata locally
kubectl patch configmap chains-config -n tekton-chains -p='{"data":{"artifacts.oci.storage": "", "artifacts.taskrun.format":"in-toto", "artifacts.taskrun.storage": "tekton"}}'
```

## Install cosign

```sh
# Download last cosign release
curl -OL https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64
# Install on /usr/local/bin/cosign
sudo install -o root -g root -m 0755 cosign-linux-amd64 /usr/local/bin/cosign
rm cosign-linux-amd64
# Autocompletion
cosign completion bash | sudo tee /etc/bash_completion.d/cosign_completion
source ~/.bashrc
# Verify
cosign version
cosign --help
```

## Generate a key pair to sign the artifact provenance

```sh
cosign generate-key-pair k8s://tekton-chains/signing-secrets
```

## Build and push a container image

```sh
# EventListener in event-listener.yaml
# 
```

## TODO

- todo
