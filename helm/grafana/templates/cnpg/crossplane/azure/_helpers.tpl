
{{/*
Sanitize storage account name for Azure
Azure storage account names must be:
- Between 3 and 24 characters
- Lowercase letters and numbers only
- Globally unique
*/}}
{{- define "grafana.crossplane.azure.storageAccountName" -}}
{{- $containerName := .containerName -}}
{{- $sanitized := regexReplaceAll "[^a-z0-9]" (lower $containerName) "" -}}
{{- $sanitized | trunc 24 -}}
{{- end -}}

{{/*
Check if Azure cluster is private
Reads the cluster user-values ConfigMap and checks global.connectivity.network.mode
*/}}
{{- define "grafana.crossplane.azure.isPrivateCluster" -}}
{{- $clusterName := .Values.postgresqlCluster.crossplane.clusterName -}}
{{- $isPrivate := false -}}
{{- $configMapName := printf "%s-user-values" $clusterName -}}
{{- $configMap := lookup "v1" "ConfigMap" "org-giantswarm" $configMapName -}}
{{- if $configMap -}}
  {{- if $configMap.data -}}
    {{- if $configMap.data.values -}}
      {{- $values := $configMap.data.values | fromYaml -}}
      {{- if $values.global -}}
        {{- if $values.global.connectivity -}}
          {{- if $values.global.connectivity.network -}}
            {{- if eq ($values.global.connectivity.network.mode | toString) "private" -}}
              {{- $isPrivate = true -}}
            {{- end -}}
          {{- end -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- $isPrivate -}}
{{- end -}}

{{/*
Get Azure Subscription ID from AzureCluster
*/}}
{{- define "grafana.crossplane.azure.subscriptionId" -}}
{{- $clusterName := .Values.postgresqlCluster.crossplane.clusterName -}}
{{- $clusterNamespace := .Values.postgresqlCluster.crossplane.clusterNamespace -}}
{{- $subscriptionId := "" -}}
{{- $azureCluster := lookup "infrastructure.cluster.x-k8s.io/v1beta1" "AzureCluster" $clusterNamespace $clusterName -}}
{{- if $azureCluster -}}
  {{- $subscriptionId = $azureCluster.spec.subscriptionID -}}
{{- end -}}
{{- $subscriptionId -}}
{{- end -}}

{{/*
Get Azure Resource Group from AzureCluster
*/}}
{{- define "grafana.crossplane.azure.resourceGroup" -}}
{{- $clusterName := .Values.postgresqlCluster.crossplane.clusterName -}}
{{- $clusterNamespace := .Values.postgresqlCluster.crossplane.clusterNamespace -}}
{{- $resourceGroup := "" -}}
{{- $azureCluster := lookup "infrastructure.cluster.x-k8s.io/v1beta1" "AzureCluster" $clusterNamespace $clusterName -}}
{{- if $azureCluster -}}
  {{- $resourceGroup = $azureCluster.spec.resourceGroup -}}
{{- end -}}
{{- $resourceGroup -}}
{{- end -}}

{{/*
Get Azure Location from AzureCluster
*/}}
{{- define "grafana.crossplane.azure.location" -}}
{{- $clusterName := .Values.postgresqlCluster.crossplane.clusterName -}}
{{- $clusterNamespace := .Values.postgresqlCluster.crossplane.clusterNamespace -}}
{{- $location := "" -}}
{{- $azureCluster := lookup "infrastructure.cluster.x-k8s.io/v1beta1" "AzureCluster" $clusterNamespace $clusterName -}}
{{- if $azureCluster -}}
  {{- $location = $azureCluster.spec.location -}}
{{- end -}}
{{- $location -}}
{{- end -}}

{{/*
Get Virtual Network Name from AzureCluster
*/}}
{{- define "grafana.crossplane.azure.vnetName" -}}
{{- $clusterName := .Values.postgresqlCluster.crossplane.clusterName -}}
{{- $clusterNamespace := .Values.postgresqlCluster.crossplane.clusterNamespace -}}
{{- $vnetName := "" -}}
{{- $azureCluster := lookup "infrastructure.cluster.x-k8s.io/v1beta1" "AzureCluster" $clusterNamespace $clusterName -}}
{{- if $azureCluster -}}
  {{- if $azureCluster.spec.networkSpec -}}
    {{- if $azureCluster.spec.networkSpec.vnet -}}
      {{- $vnetName = $azureCluster.spec.networkSpec.vnet.name -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- $vnetName -}}
{{- end -}}

{{/*
Get Virtual Network Resource Group from AzureCluster (may be different from cluster RG)
*/}}
{{- define "grafana.crossplane.azure.vnetResourceGroup" -}}
{{- $clusterName := .Values.postgresqlCluster.crossplane.clusterName -}}
{{- $clusterNamespace := .Values.postgresqlCluster.crossplane.clusterNamespace -}}
{{- $vnetRG := "" -}}
{{- $azureCluster := lookup "infrastructure.cluster.x-k8s.io/v1beta1" "AzureCluster" $clusterNamespace $clusterName -}}
{{- if $azureCluster -}}
  {{- if $azureCluster.spec.networkSpec -}}
    {{- if $azureCluster.spec.networkSpec.vnet -}}
      {{- $vnetRG = $azureCluster.spec.networkSpec.vnet.resourceGroup | default $azureCluster.spec.resourceGroup -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- $vnetRG -}}
{{- end -}}

{{/*
Get Subnet ID for private endpoint
*/}}
{{- define "grafana.crossplane.azure.subnetId" -}}
{{- $clusterName := .Values.postgresqlCluster.crossplane.clusterName -}}
{{- $clusterNamespace := .Values.postgresqlCluster.crossplane.clusterNamespace -}}
{{- $subnetId := "" -}}
{{- $azureCluster := lookup "infrastructure.cluster.x-k8s.io/v1beta1" "AzureCluster" $clusterNamespace $clusterName -}}
{{- if $azureCluster -}}
  {{- if $azureCluster.spec.networkSpec -}}
    {{- if $azureCluster.spec.networkSpec.subnets -}}
      {{- range $azureCluster.spec.networkSpec.subnets -}}
        {{- if eq .role "control-plane" -}}
          {{- $subnetId = .id -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- $subnetId -}}
{{- end -}}
