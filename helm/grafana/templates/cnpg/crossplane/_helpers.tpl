{{/*
Crossplane enabled check
*/}}
{{- define "grafana.crossplane.enabled" -}}
{{- if and .Values.postgresqlCluster.backup.crossplane.enabled .Values.postgresqlCluster.backup.crossplane.clusterName -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/*
Crossplane is AWS/CAPA
*/}}
{{- define "grafana.crossplane.isAWS" -}}
{{- if eq .Values.postgresqlCluster.backup.crossplane.provider "aws" -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/*
Merge tags from cluster CR with user-provided tags
Returns tags as a map: {foo: "bar"}
*/}}
{{- define "grafana.crossplane.tags" -}}
{{- $clusterName := .Values.postgresqlCluster.backup.crossplane.clusterName -}}
{{- $clusterNamespace := .Values.postgresqlCluster.backup.crossplane.clusterNamespace -}}
{{- $provider := .Values.postgresqlCluster.backup.crossplane.provider -}}
{{- $tags := dict -}}
{{- if eq $provider "aws" -}}
  {{- $awsCluster := lookup "infrastructure.cluster.x-k8s.io/v1beta2" "AWSCluster" $clusterNamespace $clusterName -}}
  {{- if $awsCluster -}}
    {{- if $awsCluster.spec.additionalTags -}}
      {{- range $key, $value := $awsCluster.spec.additionalTags -}}
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
{{- $userTags := .Values.postgresqlCluster.backup.crossplane.tags | default list -}}
{{- range $tag := $userTags -}}
  {{- $_ := set $tags (index $tag "key") (index $tag "value") -}}
{{- end -}}
{{- $tags | toYaml -}}
{{- end -}}
