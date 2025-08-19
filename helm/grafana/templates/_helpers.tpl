{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "labels.common" -}}
app: {{ include "name" . | quote }}
{{ include "labels.selector" . }}
app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
application.giantswarm.io/team: {{ index .Chart.Annotations "application.giantswarm.io/team" | quote }}
helm.sh/chart: {{ include "chart" . | quote }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "labels.selector" -}}
app.kubernetes.io/name: {{ .Chart.Name | quote }}
app.kubernetes.io/instance: {{ .Chart.Name | quote }}
{{- end -}}

{{/*
Return the appropriate apiVersion for podSecurityPolicy.
*/}}
{{- define "grafana.podSecurityPolicy.apiVersion" -}}
  {{- if and (.Capabilities.APIVersions.Has "policy/v1beta1") (semverCompare ">= 1.16-0" .Capabilities.KubeVersion.Version) -}}
    {{- print "policy/v1beta1" -}}
  {{- else -}}
    {{- print "extensions/v1beta1" -}}
  {{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for podDisruptionBudget.
*/}}
{{- define "grafana.podDisruptionBudget.apiVersion" -}}
  {{- if and (.Capabilities.APIVersions.Has "policy/v1") (semverCompare ">= 1.21-0" .Capabilities.KubeVersion.Version) -}}
    {{- print "policy/v1" -}}
  {{- else -}}
    {{- print "policy/v1beta1" -}}
  {{- end -}}
{{- end -}}

{{/*
PostgreSQL provider-specific helpers
*/}}

{{/*
Check if provider is AWS (using shared-config value)
*/}}
{{- define "postgresql.isAWS" -}}
{{- if (eq $.Values.postgresql.provider.kind $.Values.postgresql.provider.awsKind) -}}
true
{{- end -}}
{{- end -}}

{{/*
Check if provider is Azure (using shared-config value)
*/}}
{{- define "postgresql.isAzure" -}}
{{- if (eq $.Values.postgresql.provider.kind $.Values.postgresql.provider.azureKind) -}}
true
{{- end -}}
{{- end -}}

{{/*
Get backup destination path based on provider
*/}}
{{- define "postgresql.backupDestinationPath" -}}
{{- if (include "postgresql.isAWS" .) -}}
{{ $.Values.postgresql.backups.aws.destinationPath }}/{{ $.Values.postgresql.grafanaDatabase.backupName }}/
{{- else if (include "postgresql.isAzure" .) -}}
{{ $.Values.postgresql.backups.azure.destinationPath }}/{{ $.Values.postgresql.grafanaDatabase.backupName }}
{{- end -}}
{{- end -}}

{{/*
Get recovery destination path based on provider
*/}}
{{- define "postgresql.recoveryDestinationPath" -}}
{{- if (include "postgresql.isAWS" .) -}}
{{ $.Values.postgresql.backups.aws.destinationPath }}/{{ $.Values.postgresql.grafanaDatabase.recoveryBackupName }}/
{{- else if (include "postgresql.isAzure" .) -}}
{{ $.Values.postgresql.backups.azure.destinationPath }}/{{ $.Values.postgresql.grafanaDatabase.recoveryBackupName }}
{{- end -}}
{{- end -}}

{{/*
Get AWS IAM role ARN (from shared-config)
*/}}
{{- define "postgresql.awsIamRoleArn" -}}
{{ $.Values.postgresql.provider.aws.iamRoleArn }}
{{- end -}}

{{/*
Get Azure storage account name (from shared-config)
*/}}
{{- define "postgresql.azureStorageAccountName" -}}
{{ $.Values.postgresql.provider.azure.storageAccountName }}
{{- end -}}