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
