# How To Build a Kubernetes Operator From Scratch

## About

> [`https://thenewstack.io/how-to-build-a-kubernetes-operator-from-scratch/`](https://thenewstack.io/how-to-build-a-kubernetes-operator-from-scratch/)

Operators streamline workflows, reduce manual intervention and support infrastructure management, key skills for anyone working in DevOps.

- May 6th, 2025 4:00pm
- by [Joshua Masiko](https://thenewstack.io/author/joshua-masiko/)

## Prerequisites

Start by installing all the necessary tools to build and run your Kubernetes operator:

- Docker
- kubectl
- Kind
- Go
- Kubebuilder

Verify your installations

```bash￼
docker --version
kubectl version --client
kind version
go version
kubebuilder version
```

## Set Up a Cluster With Kind

```bash
# Create a Kubernetes cluster using Kind
kind create cluster --name self-healing-lab
 
# Verify the cluster is running
kubectl cluster-info
```

## Test Application

```bash
mkdir -p fragile-app

cd fragile-app

go mod init 7f000001.nip.io/fragile-app

touch main.go

touch Dockerfile
```

- [`main.go`](./fragile-app/main.go)
- [`Dockerfile`](./fragile-app/Dockerfile)

```bash
# build the docker image
docker build -t fragile-app:latest .

# run it locally
docker run -p 8910:80 --rm fragile-app:latest

# send requests to the app in another terminal
# it should crash after 5 requests
for i in {1..6}; do curl localhost:8910; echo; done
```

## Deploy to Kubernetes

- Deployment manifest [`fragile-app-deployment.yaml`]()

```bash
# load the local image into Kind
kind load docker-image fragile-app:latest --name self-headling-lab

# apply the deployment
kubectl apply -f fragile-app-deployment.yaml

# check that the pod is running
kubectl get pods

# test the app
# port forward to the pod
POD_NAME=$(kubectl get pods -l app=fragile-app -o jsonpath="{.items[0
].metadata.name}")
echo $POD_NAME
kubectl port-forward $POD_NAME 8910:80

# monitoring the app in another terminal
watch -n 1 kubectl get pods

# send requests to the app in another terminal
# it should crash after 5 requests
for i in {1..6}; do curl localhost:8910; echo; done
```

## Understanding the Operator Pattern

**What Is a Kubernetes Operator**?

An operator is a pattern that extends Kubernetes to handle application-specific operational tasks. It works by doing the following:

- It defines custom resources (i.e., CRDs) that represent your application’s desired state.
- It implements controllers that continuously reconcile the actual state with the desired state.

Think of operators as automated domain experts that can monitor your application’s health, react to changes or problems, and apply specialized knowledge to fix issues.

**The Reconciliation Loop**.

The heart of the operator is the reconciliation loop! Think of it as Kubernetes’ way of constantly moving from the current state to the desired state.

```bash
┌─────────────┐            ┌─────────────┐
│  Observed   │            │   Desired   │
│    State    │─────────►  │    State    │
└─────────────┘            └─────────────┘
       ▲                          │
       │                          │
       │                          ▼
       │                  ┌──────────────┐
       └───────────────── │ Reconcile()  │
                          └──────────────┘
```

The controller is triggered whenever a pod changes. Then it:

- Checks if the pod matches any PodDiagnoser’s target labels.
- Examines container restart information.
- Adds diagnostic annotations if crashes are detected.
- Applies any configured remediation actions.

This cycle repeats continuously, ensuring your pods always have up-to-date diagnostic information!

## Building an operator

Initialize the operator project:

```bash
# create a directory for the operator
mkdir -p pod-diagnoser-operator
cd pod-diagnoser-operator/

# initialize the project with kubebuilder
kubebuilder init --domain=7f000001.nip.io --repo=7f000001.nip.io/pod-diagnoser

# create the API and controller
kubebuilder create api --group=diagnostics --version=v1 --kind=PodDiagnoser --resource=true --controller=true
```

Define the CRD by editing the `api/v1/poddiagnoser_types.go` file:

```go
/*
Copyright 2025.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package v1

import (
  metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// EDIT THIS FILE!  THIS IS SCAFFOLDING FOR YOU TO OWN!
// NOTE: json tags are required.  Any new fields you add must have json tags for the fields to be serialized.

// PodDiagnoserSpec defines the desired state of PodDiagnoser.
type PodDiagnoserSpec struct {
  // TargetLabels specifies which pods to monitor based on labels
  // +optional
  TargetLabels map[string]string `json:"targetLabels,omitempty"`

  // EnableAnnotations determines whether to add diagnostic annotations
  // +optional
  EnableAnnotations bool `json:"enableAnnotations,omitempty"`

  // RemediationsAction specifies what action to take when crashes are detected
  // +optional
  RemediationAction string `json:"remediationAction,omitempty"`
}

// PodDiagnoserStatus defines the observed state of PodDiagnoser.
type PodDiagnoserStatus struct {
  // LastProcessedPod is the last pod that was processed
  // +optional
  LastProcessedPod string `json:"lastProcessedPod,omitempty"`

  // DiagnosedPods contains the count of pods that have been diagnosed
  // +optional
  DiagnosedPods int `json:"diagnosedPods,omitempty"`
}

// +kubebuilder:object:root=true
// +kubebuilder:subresource:status

// PodDiagnoser is the Schema for the poddiagnosers API.
type PodDiagnoser struct {
  metav1.TypeMeta   `json:",inline"`
  metav1.ObjectMeta `json:"metadata,omitempty"`

  Spec   PodDiagnoserSpec   `json:"spec,omitempty"`
  Status PodDiagnoserStatus `json:"status,omitempty"`
}

// +kubebuilder:object:root=true

// PodDiagnoserList contains a list of PodDiagnoser.
type PodDiagnoserList struct {
  metav1.TypeMeta `json:",inline"`
  metav1.ListMeta `json:"metadata,omitempty"`
  Items           []PodDiagnoser `json:"items"`
}

func init() {
  SchemeBuilder.Register(&PodDiagnoser{}, &PodDiagnoserList{})
}
```

Updating the code:

```bash
make generate
```

Implement the controller by editing the `internal/controller/poddiagnoser_controller.go` file:

```go
package controller

import (
  "context"
  "fmt"
  "time"

  corev1 "k8s.io/api/core/v1"
  "k8s.io/apimachinery/pkg/api/errors"
  "k8s.io/apimachinery/pkg/runtime"
  "k8s.io/client-go/tools/record"
  "k8s.io/client-go/util/retry"
  ctrl "sigs.k8s.io/controller-runtime"
  "sigs.k8s.io/controller-runtime/pkg/client"
  "sigs.k8s.io/controller-runtime/pkg/log"

  diagnosticsv1 "7f000001.nip.io/pod-diagnoser/api/v1"
)

// PodDiagnoserReconciler reconciles a PodDiagnoser object
type PodDiagnoserReconciler struct {
  client.Client
  Scheme   *runtime.Scheme
  Recorder record.EventRecorder // Add event recorder
}

//+kubebuilder:rbac:groups=diagnostics.7f000001.nip.io,resources=poddiagnosers,verbs=get;list;watch;create;update;patch;delete
//+kubebuilder:rbac:groups=diagnostics.7f000001.nip.io,resources=poddiagnosers/status,verbs=get;update;patch
//+kubebuilder:rbac:groups=diagnostics.7f000001.nip.io,resources=poddiagnosers/finalizers,verbs=update
//+kubebuilder:rbac:groups="",resources=pods,verbs=get;list;watch;update;patch
//+kubebuilder:rbac:groups="",resources=events,verbs=create;patch

// Reconcile is part of the main kubernetes reconciliation loop
func (r *PodDiagnoserReconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
  logger := log.FromContext(ctx)

  // Get the pod that triggered reconciliation
  pod := &corev1.Pod{}
  if err := r.Get(ctx, req.NamespacedName, pod); err != nil {
    if errors.IsNotFound(err) {
      // Pod was deleted, nothing to do
      return ctrl.Result{}, nil
    }
    logger.Error(err, "Unable to fetch Pod")
    return ctrl.Result{}, err
  }

  // Get all PodDiagnosers
  diagnoserList := &diagnosticsv1.PodDiagnoserList{}
  if err := r.List(ctx, diagnoserList); err != nil {
    logger.Error(err, "Unable to list PodDiagnosers")
    return ctrl.Result{}, err
  }

  // Check if this pod should be diagnosed based on PodDiagnoser rules
  var matchingDiagnoser *diagnosticsv1.PodDiagnoser
  for i := range diagnoserList.Items {
    diagnoser := &diagnoserList.Items[i]
    if shouldDiagnosePod(diagnoser, pod) {
      matchingDiagnoser = diagnoser
      break
    }
  }

  if matchingDiagnoser == nil {
    // No matching diagnoser for this pod
    return ctrl.Result{}, nil
  }

  // Check for container restarts and diagnose
  updated := false
  for _, containerStatus := range pod.Status.ContainerStatuses {
    if containerStatus.RestartCount > 0 && containerStatus.LastTerminationState.Terminated != nil {
      // Container has restarted at least once
      if pod.Annotations == nil {
        pod.Annotations = make(map[string]string)
      }

      // Add diagnostic annotations
      restartReason := containerStatus.LastTerminationState.Terminated.Reason
      exitCode := containerStatus.LastTerminationState.Terminated.ExitCode
      restartTime := containerStatus.LastTerminationState.Terminated.FinishedAt.Time

      pod.Annotations["diagnostics.7f000001.nip.io/restart-reason"] =
        fmt.Sprintf("%s (Exit Code: %d)", restartReason, exitCode)
      pod.Annotations["diagnostics.7f000001.nip.io/restart-time"] =
        restartTime.Format(time.RFC3339)

      updated = true

      logger.Info("Diagnosed pod restart",
        "pod", pod.Name,
        "container", containerStatus.Name,
        "reason", restartReason,
        "exitCode", exitCode)
    }
  }

  if updated {
    // Update the pod with new annotations using retry for robustness
    if err := retry.RetryOnConflict(retry.DefaultRetry, func() error {
      // Get the latest version to avoid conflicts
      latest := &corev1.Pod{}
      if err := r.Get(ctx, req.NamespacedName, latest); err != nil {
        return err
      }

      // Update annotations
      if latest.Annotations == nil {
        latest.Annotations = make(map[string]string)
      }
      latest.Annotations["diagnostics.7f000001.nip.io/restart-reason"] =
        pod.Annotations["diagnostics.7f000001.nip.io/restart-reason"]
      latest.Annotations["diagnostics.7f000001.nip.io/restart-time"] =
        pod.Annotations["diagnostics.7f000001.nip.io/restart-time"]

      return r.Update(ctx, latest)
    }); err != nil {
      logger.Error(err, "Failed to update Pod with diagnostic annotations")
      return ctrl.Result{}, err
    }

    // Update the diagnoser status with retry for robustness
    if err := retry.RetryOnConflict(retry.DefaultRetry, func() error {
      // Get the latest version
      latest := &diagnosticsv1.PodDiagnoser{}
      if err := r.Get(ctx, client.ObjectKey{
        Namespace: matchingDiagnoser.Namespace,
        Name:      matchingDiagnoser.Name,
      }, latest); err != nil {
        return err
      }

      latest.Status.LastProcessedPod = pod.Name
      latest.Status.DiagnosedPods++
      return r.Status().Update(ctx, latest)
    }); err != nil {
      logger.Error(err, "Unable to update PodDiagnoser status")
      return ctrl.Result{}, err
    }

    // Apply remediation if configured
    if matchingDiagnoser.Spec.RemediationAction != "" {
      if err := r.applyRemediation(ctx, matchingDiagnoser, pod); err != nil {
        logger.Error(err, "Failed to apply remediation")
        return ctrl.Result{}, err
      }
    }
  }

  return ctrl.Result{}, nil
}

// shouldDiagnosePod determines if this pod should be diagnosed by the given diagnoser
func shouldDiagnosePod(diagnoser *diagnosticsv1.PodDiagnoser, pod *corev1.Pod) bool {
  if !diagnoser.Spec.EnableAnnotations {
    return false
  }

  // If no target labels specified, match all pods
  if len(diagnoser.Spec.TargetLabels) == 0 {
    return true
  }

  // Check if pod matches all target labels
  for key, value := range diagnoser.Spec.TargetLabels {
    if pod.Labels[key] != value {
      return false
    }
  }

  return true
}

// applyRemediation applies remediation based on the diagnoser configuration
func (r *PodDiagnoserReconciler) applyRemediation(ctx context.Context,
  diagnoser *diagnosticsv1.PodDiagnoser, pod *corev1.Pod) error {

  logger := log.FromContext(ctx)

  switch diagnoser.Spec.RemediationAction {
  case "RestartPod":
    logger.Info("Applying remediation: restarting pod", "pod", pod.Name)
    // Just delete the pod, the deployment controller will create a new one
    return r.Delete(ctx, pod)

  case "LogEvent":
    // Use the Kubernetes event recorder to log an event
    r.Recorder.Event(pod,
      corev1.EventTypeWarning,
      "PodRestarted",
      fmt.Sprintf("Pod %s restarted due to %s (Exit Code: %d)",
        pod.Name,
        pod.Annotations["diagnostics.7f000001.nip.io/restart-reason"],
        pod.Status.ContainerStatuses[0].LastTerminationState.Terminated.ExitCode))
    return nil

  default:
    logger.Info("No remediation action defined or unknown action",
      "action", diagnoser.Spec.RemediationAction)
    return nil
  }
}

// SetupWithManager sets up the controller with the Manager.
func (r *PodDiagnoserReconciler) SetupWithManager(mgr ctrl.Manager) error {
  // Initialize the event recorder
  r.Recorder = mgr.GetEventRecorderFor("pod-diagnoser")

  return ctrl.NewControllerManagedBy(mgr).
    For(&corev1.Pod{}).
    Complete(r)
}
```
