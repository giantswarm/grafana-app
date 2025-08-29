{{/*
Common labels
*/}}
{{- define "grafana.labels" -}}
helm.sh/chart: {{ include "grafana.chart" . }}
{{ include "grafana.selectorLabels" . }}
{{- if or .Chart.AppVersion .Values.image.tag }}
app.kubernetes.io/version: {{ .Values.image.tag | default .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Values.extraLabels }}
{{ toYaml .Values.extraLabels }}
{{- end }}
application.giantswarm.io/team: {{ index .Chart.Annotations "application.giantswarm.io/team" | default "atlas" | quote }}
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