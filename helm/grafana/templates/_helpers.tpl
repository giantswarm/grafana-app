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
Constructs the full AWS IAM Role ARN.
*/}}
{{- define "aws.iamRoleArn" -}}
{{- printf "arn:aws:iam::%s:role/%s" .Values.global.provider.account (include "chart.storageBucket.name" .) -}}
{{- end -}}

{{/*
Constructs the S3 destination path for new backups.
Result: s3://<bucket-name>/<backup-name>/
*/}}
{{- define "s3.backupPath" -}}
{{- printf "s3://%s/%s/" (include "chart.storageBucket.name" .) .Values.postgresql.backup.name -}}
{{- end -}}

{{/*
Constructs the S3 source path for recovery.
Result: s3://<bucket-name>/<recovery-name>/
*/}}
{{- define "s3.recoveryPath" -}}
{{- printf "s3://%s/%s/" (include "chart.storageBucket.name" .) .Values.postgresql.recovery.name -}}
{{- end -}}

{{/*
Constructs the Azure Blob Storage destination path for backups.
The storage account name is truncated to 24 characters as required by Azure.
*/}}
{{- define "azure.backupPath" -}}
{{- $accountName := printf "%.24s" (include "chart.storageBucket.name" .) -}}
{{- printf "https://%s.blob.core.windows.net/giantswarm-%s-%s" $accountName .Values.global.codename .Values.postgresql.backup.name -}}
{{- end -}}

{{/*
Constructs the Azure Blob Storage source path for recovery.
*/}}
{{- define "azure.recoveryPath" -}}
{{- $accountName := printf "%.24s" (include "chart.storageBucket.name" .) -}}
{{- printf "https://%s.blob.core.windows.net/giantswarm-%s-%s" $accountName .Values.global.codename .Values.postgresql.recovery.name -}}
{{- end -}}
