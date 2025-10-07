{{- define "templating-deep-dive.fullname" -}}
{{- $defaultName := printf "%s-%s" .Release.Name .Chart.Name }}
{{- .Values.customName | default $defaultName | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "templating-deep-dive.selectorLabels" -}}
app: {{ .Chart.Name }}
release: {{ .Release.Name }}
created-by: "Tarso"
{{- end -}}

