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
