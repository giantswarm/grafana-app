{{/*
Crossplane enabled check
*/}}
{{- define "grafana.crossplane.enabled" -}}
{{- if and .Values.postgresqlCluster.enabled .Values.postgresqlCluster.backup.enabled .Values.postgresqlCluster.crossplane.enabled -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/*
Crossplane is AWS/CAPA
*/}}
{{- define "grafana.crossplane.isAWS" -}}
{{- if eq .Values.postgresqlCluster.crossplane.provider "aws" -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/*
Crossplane is Azure/CAPZ
*/}}
{{- define "grafana.crossplane.isAzure" -}}
{{- if eq .Values.postgresqlCluster.crossplane.provider "azure" -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/*
Merge tags from cluster CR with user-provided tags
Returns tags as a map: {foo: "bar"}
For Azure, hyphens in tag keys are replaced with underscores for compatibility.
*/}}
{{- define "grafana.crossplane.tags" -}}
{{- $clusterName := .Values.postgresqlCluster.crossplane.clusterName -}}
{{- $clusterNamespace := .Values.postgresqlCluster.crossplane.clusterNamespace -}}
{{- $clusterProvider := .Values.postgresqlCluster.crossplane.clusterProvider | default .Values.postgresqlCluster.crossplane.provider -}}
{{- $storageProvider := .Values.postgresqlCluster.crossplane.provider -}}
{{- $tags := dict -}}
{{- if eq $clusterProvider "aws" -}}
  {{- $awsCluster := lookup "infrastructure.cluster.x-k8s.io/v1beta2" "AWSCluster" $clusterNamespace $clusterName -}}
  {{- if $awsCluster -}}
    {{- if $awsCluster.spec.additionalTags -}}
      {{- range $key, $value := $awsCluster.spec.additionalTags -}}
        {{- $_ := set $tags $key $value -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- else if eq $clusterProvider "azure" -}}
  {{- $azureCluster := lookup "infrastructure.cluster.x-k8s.io/v1beta1" "AzureCluster" $clusterNamespace $clusterName -}}
  {{- if $azureCluster -}}
    {{- if $azureCluster.spec.additionalTags -}}
      {{- range $key, $value := $azureCluster.spec.additionalTags -}}
        {{- $_ := set $tags $key $value -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- else if eq $clusterProvider "vsphere" -}}
  {{- $vsphereCluster := lookup "infrastructure.cluster.x-k8s.io/v1beta1" "VSphereCluster" $clusterNamespace $clusterName -}}
  {{- if $vsphereCluster -}}
    {{- if $vsphereCluster.spec.additionalTags -}}
      {{- range $key, $value := $vsphereCluster.spec.additionalTags -}}
        {{- $_ := set $tags $key $value -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- else if eq $clusterProvider "cloud-director" -}}
  {{- $vcdCluster := lookup "infrastructure.cluster.x-k8s.io/v1beta1" "VCDCluster" $clusterNamespace $clusterName -}}
  {{- if $vcdCluster -}}
    {{- if $vcdCluster.spec.additionalTags -}}
      {{- range $key, $value := $vcdCluster.spec.additionalTags -}}
        {{- $_ := set $tags $key $value -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- $defaultTags := dict
  "app" "grafana-postgresql"
  "managed-by" "crossplane"
-}}
{{- $tags = merge $tags $defaultTags -}}
{{- $userTags := .Values.postgresqlCluster.crossplane.tags | default list -}}
{{- range $tag := $userTags -}}
  {{- $_ := set $tags (index $tag "key") (index $tag "value") -}}
{{- end -}}
{{- if eq $storageProvider "azure" -}}
  {{- $sanitizedTags := dict -}}
  {{- range $key, $value := $tags -}}
    {{- $sanitizedKey := $key | replace "-" "_" -}}
    {{- $_ := set $sanitizedTags $sanitizedKey $value -}}
  {{- end -}}
  {{- $tags = $sanitizedTags -}}
{{- end -}}
{{- $tags | toYaml -}}
{{- end -}}

{{/*
Sorted labels for crossplane resources (alphabetical order for linting compliance).
Usage: include "grafana.crossplane.labels" (dict "ctx" . "component" "storage")
*/}}
{{- define "grafana.crossplane.labels" -}}
{{- $ctx := .ctx -}}
{{- $component := .component | default "" -}}
{{- if $component -}}
app.kubernetes.io/component: {{ $component }}
{{ end -}}
app.kubernetes.io/instance: {{ $ctx.Chart.Name | quote }}
app.kubernetes.io/managed-by: {{ $ctx.Release.Service }}
app.kubernetes.io/name: {{ $ctx.Chart.Name | quote }}
{{- if $ctx.Chart.AppVersion }}
app.kubernetes.io/version: {{ $ctx.Chart.AppVersion | quote }}
{{- end }}
application.giantswarm.io/team: {{ index $ctx.Chart.Annotations "io.giantswarm.application.team" | default "atlas" | quote }}
helm.sh/chart: {{ include "grafana.chart" $ctx }}
{{- end -}}
