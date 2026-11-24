#!/usr/bin/env bash
set -e

PROJECT="${1}"
SERVICE="${2}"
ENVIRONMENT="${3}"
CLUSTER_NAME="${6}"

echo "Get aks credentials"

az aks get-credentials \
    --resource-group "${PROJECT}-${ENVIRONMENT}-${CLUSTER_NAME}-rg" \
    --name "${PROJECT}-${ENVIRONMENT}-${CLUSTER_NAME}-${SERVICE}" \
    --overwrite-existing

: "${SYSTEM_ACCESSTOKEN:?SYSTEM_ACCESSTOKEN is required}"
: "${SYSTEM_OIDCREQUESTURI:?SYSTEM_OIDCREQUESTURI is required}"
: "${AZURESUBSCRIPTION_TENANT_ID:?Service connection tenant ID is required}"
: "${AZURESUBSCRIPTION_CLIENT_ID:?Service connection client ID is required}"
: "${AZURESUBSCRIPTION_SERVICE_CONNECTION_ID:?Service connection ID is required}"

kubelogin convert-kubeconfig \
    --login azurepipelines \
    --tenant-id "${AZURESUBSCRIPTION_TENANT_ID}" \
    --client-id "${AZURESUBSCRIPTION_CLIENT_ID}" \
    --azure-pipelines-service-connection-id "${AZURESUBSCRIPTION_SERVICE_CONNECTION_ID}" \
    --disable-environment-override