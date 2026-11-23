{{/*
Object store credentials for CNPG barman-cloud ObjectStore resources.

Outputs the appropriate credentials block based on the configured storage type.
Intended to be called with `{{- include "grafana.cnpg.objectStoreCredentials" . | nindent 4 }}`.

Credential paths:

  S3 with explicit keys:
    Condition: objectStorage.type == "s3" AND s3.accessKeyId AND s3.secretAccessKey are set
    Use case: customers providing their own S3 bucket with static credentials
    Source: the <cluster-name>-access-keys Secret (rendered by access-keys-secret.yaml)

  S3 with an existing Secret:
    Condition: objectStorage.type == "s3", no explicit keys, and s3.existingSecret.name set
      or, on the Standalone Observability Platform, global.objectStorage (backend s3)
    Use case: dedicated backup keys, or the platform's credentials Secret
    Source: that Secret; the region from the <cluster-name>-s3-region Secret
            (rendered by s3-region-secret.yaml), as barman reads it from a Secret

  S3 with IRSA:
    Condition: objectStorage.type == "s3", no explicit keys, no Secret
    Use case: AWS/CAPA clusters with an IAM role configured for the CNPG service account
    Source: pod's IAM role via IRSA (no secret needed)

  On every S3 path but explicit keys, endpointURL comes from s3.endpointURL or, falling
  back to global.objectStorage, from its endpoint and `insecure`. s3.endpointCA adds a CA
  bundle on every S3 path.

  Azure with Crossplane:
    Condition: objectStorage.type == "azure" AND crossplane.azure.enabled == true
    Use case: CAPZ clusters where Crossplane provisions the storage account
    Source: connection string from the Crossplane-generated secret
             (key: attribute.primary_blob_connection_string)

  Azure manual:
    Condition: objectStorage.type == "azure", Crossplane not enabled
    Use case: non-Crossplane Azure installs with an existing storage account
    Source: azureCredentials passthrough from objectStorage.azure.credentials
*/}}
{{- define "grafana.cnpg.objectStoreCredentials" -}}
{{- if eq .Values.postgresqlCluster.objectStorage.type "s3" }}
{{- if and .Values.postgresqlCluster.objectStorage.s3.accessKeyId .Values.postgresqlCluster.objectStorage.s3.secretAccessKey }}
endpointURL: {{ .Values.postgresqlCluster.objectStorage.s3.endpointURL }}
s3Credentials:
  region: {{ .Values.postgresqlCluster.objectStorage.s3.region }}
  accessKeyId:
    name: {{ .Values.postgresqlCluster.name }}-access-keys
    key: ACCESS_KEY_ID
  secretAccessKey:
    name: {{ .Values.postgresqlCluster.name }}-access-keys
    key: SECRET_ACCESS_KEY
{{- else }}
{{- with include "grafana.cnpg.s3.endpointURL" . }}
endpointURL: {{ . }}
{{- end }}
{{- $secret := include "grafana.cnpg.s3.credentialsSecret" . | fromJson }}
s3Credentials:
{{- if $secret.name }}
  accessKeyId:
    name: {{ $secret.name }}
    key: {{ $secret.accessKeyIdKey }}
  secretAccessKey:
    name: {{ $secret.name }}
    key: {{ $secret.secretAccessKeyKey }}
  {{- if include "grafana.cnpg.s3.region" . }}
  region:
    name: {{ .Values.postgresqlCluster.name }}-s3-region
    key: REGION
  {{- end }}
{{- else }}
  inheritFromIAMRole: true
{{- end }}
{{- end }}
{{- with .Values.postgresqlCluster.objectStorage.s3.endpointCA }}
{{- if .name }}
endpointCA:
  name: {{ .name }}
  key: {{ .key }}
{{- end }}
{{- end }}
{{- else if eq .Values.postgresqlCluster.objectStorage.type "azure" }}
{{- if .Values.postgresqlCluster.crossplane.azure.enabled }}
azureCredentials:
  connectionString:
    name: {{ .Values.postgresqlCluster.crossplane.azure.container.name }}
    key: attribute.primary_blob_connection_string
{{- else }}
{{- with .Values.postgresqlCluster.objectStorage.azure.credentials }}
azureCredentials:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}
{{- else }}
{{- fail "Unsupported object storage type. Supported types are 's3' and 'azure'." }}
{{- end }}
{{- end -}}

{{/*
Whether S3 backups fall back to the parent chart's `global.objectStorage`: the Standalone
Observability Platform sets it, management clusters don't. True ("true") when the parent's
backend is s3 and this chart sets no endpoint and no inline key pair of its own.
*/}}
{{- define "grafana.cnpg.s3.useGlobal" -}}
{{- $s3 := .Values.postgresqlCluster.objectStorage.s3 -}}
{{- $global := dig "objectStorage" dict (.Values.global | default dict) -}}
{{- if and (eq .Values.postgresqlCluster.objectStorage.type "s3") (eq (dig "backend" "" $global) "s3") (not $s3.endpointURL) (not (and $s3.accessKeyId $s3.secretAccessKey)) -}}
true
{{- end -}}
{{- end -}}

{{/*
The S3 endpoint URL for paths other than explicit keys: s3.endpointURL, or, falling back to
global.objectStorage, its scheme-less `host[:port]` with http when `insecure`, else https.
Empty when neither is set (the IAM role on AWS S3).
*/}}
{{- define "grafana.cnpg.s3.endpointURL" -}}
{{- $s3 := .Values.postgresqlCluster.objectStorage.s3 -}}
{{- if $s3.endpointURL -}}
{{- $s3.endpointURL -}}
{{- else if include "grafana.cnpg.s3.useGlobal" . -}}
{{- $global := .Values.global.objectStorage.s3 | default dict -}}
{{- if not $global.endpoint -}}
{{- fail "postgresqlCluster.backup falls back to global.objectStorage, but global.objectStorage.s3.endpoint is empty. Set it, or set postgresqlCluster.objectStorage.s3.endpointURL." -}}
{{- end -}}
{{- if $global.insecure }}http{{ else }}https{{ end }}://{{ $global.endpoint }}
{{- end -}}
{{- end -}}

{{/*
The S3 region: s3.region, or global.objectStorage.s3.region when falling back to it.
*/}}
{{- define "grafana.cnpg.s3.region" -}}
{{- $s3 := .Values.postgresqlCluster.objectStorage.s3 -}}
{{- if $s3.region -}}
{{- $s3.region -}}
{{- else if include "grafana.cnpg.s3.useGlobal" . -}}
{{- dig "objectStorage" "s3" "region" "" (.Values.global | default dict) -}}
{{- end -}}
{{- end -}}

{{/*
The Secret holding the S3 keys, as JSON {name, accessKeyIdKey, secretAccessKeyKey}: the
dedicated s3.existingSecret, else the parent's global.objectStorage.existingSecret when
falling back to it; the render fails when the fallback has neither. name is empty when there
is none (explicit keys or the IAM role).
*/}}
{{- define "grafana.cnpg.s3.credentialsSecret" -}}
{{- $s3 := .Values.postgresqlCluster.objectStorage.s3 -}}
{{- $existing := $s3.existingSecret | default dict -}}
{{- if $existing.name -}}
{{- dict "name" $existing.name "accessKeyIdKey" ($existing.accessKeyIdKey | default "AWS_ACCESS_KEY_ID") "secretAccessKeyKey" ($existing.secretAccessKeyKey | default "AWS_SECRET_ACCESS_KEY") | toJson -}}
{{- else if include "grafana.cnpg.s3.useGlobal" . -}}
{{- if not .Values.global.objectStorage.existingSecret -}}
{{- fail "postgresqlCluster.backup falls back to global.objectStorage, but neither global.objectStorage.existingSecret nor postgresqlCluster.objectStorage.s3.existingSecret names a credentials Secret. Without one, barman would use the IAM role against the platform's store and backups would fail at runtime." -}}
{{- end -}}
{{- dict "name" .Values.global.objectStorage.existingSecret "accessKeyIdKey" "AWS_ACCESS_KEY_ID" "secretAccessKeyKey" "AWS_SECRET_ACCESS_KEY" | toJson -}}
{{- else -}}
{{- dict "name" "" | toJson -}}
{{- end -}}
{{- end -}}

{{/*
The backup destination: backup.destinationPath, or s3://<bucket>/ with the parent's
global.objectStorage.buckets.grafanaPostgresql (default grafana-postgresql) when falling
back to it.
*/}}
{{- define "grafana.cnpg.backup.destinationPath" -}}
{{- if .Values.postgresqlCluster.backup.destinationPath -}}
{{- .Values.postgresqlCluster.backup.destinationPath -}}
{{- else if include "grafana.cnpg.s3.useGlobal" . -}}
s3://{{ dig "objectStorage" "buckets" "grafanaPostgresql" "" .Values.global | default "grafana-postgresql" }}/
{{- end -}}
{{- end -}}
