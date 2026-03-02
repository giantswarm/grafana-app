{{/*
Object store credentials for CNPG barman-cloud ObjectStore resources.

Outputs the appropriate credentials block based on the configured storage type.
Intended to be called with `{{- include "grafana.cnpg.objectStoreCredentials" . | nindent 4 }}`.

Credential paths:

  S3 with explicit keys:
    Condition: objectStorage.type == "s3" AND s3.accessKeyId AND s3.secretAccessKey are set
    Use case: customers providing their own S3 bucket with static credentials
    Source: the <cluster-name>-access-keys Secret (rendered by access-keys-secret.yaml)

  S3 with IRSA:
    Condition: objectStorage.type == "s3", no explicit keys
    Use case: AWS/CAPA clusters with an IAM role configured for the CNPG service account
    Source: pod's IAM role via IRSA (no secret needed)

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
s3Credentials:
  inheritFromIAMRole: true
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
