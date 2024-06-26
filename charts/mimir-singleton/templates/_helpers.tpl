{{/*
Expand the name of the chart.
*/}}
{{- define "mimir-singleton.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "mimir-singleton.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "mimir-singleton.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "mimir-singleton.labels" -}}
helm.sh/chart: {{ include "mimir-singleton.chart" . }}
{{ include "mimir-singleton.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "mimir-singleton.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mimir-singleton.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "mimir-singleton.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "mimir-singleton.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Calculate the config from structured and unstructured text input
*/}}
{{- define "mimir-singleton.calculatedConfig" -}}
{{ tpl (mergeOverwrite (tpl .Values.config.config . | fromYaml) .Values.config.structuredConfig | toYaml) . }}
{{- end -}}

{{/*
Renders the overrides config
*/}}
{{- define "mimir-singleton.overridesConfig" -}}
{{ tpl .Values.overrides.overrides . }}
{{- end -}}

{{/*
The volume to mount for tempo runtime configuration
*/}}
{{- define "mimir-singleton.runtimeVolume" -}}
configMap:
  name: {{ tpl .Values.overrides.externalRuntimeConfigName . }}
  items:
    - key: "overrides.yaml"
      path: "overrides.yaml"
{{- end -}}

{{/*
Internal servers http listen port - derived from Mimir default
*/}}
{{- define "mimir-singleton.serverHttpListenPort" -}}
{{ (((.Values.config).structuredConfig).server).http_listen_port | default "8080" }}
{{- end -}}

{{/*
Internal servers grpc listen port - derived from Mimir default
*/}}
{{- define "mimir-singleton.serverGrpcListenPort" -}}
{{ (((.Values.config).structuredConfig).server).grpc_listen_port | default "9095" }}
{{- end -}}