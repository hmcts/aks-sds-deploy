#!/usr/bin/env bash
set -e

PROJECT="${1}"
SERVICE="${2}"
ENVIRONMENT="${3}"
CLUSTER_NAME="${6}"
echo  "Get aks credentials "

az aks get-credentials \
    --resource-group "${PROJECT}"-"${ENVIRONMENT}"-"${CLUSTER_NAME}"-rg \
    --name "${PROJECT}"-"${ENVIRONMENT}"-"${CLUSTER_NAME}"-"${SERVICE}" \
    --overwrite-existing

# Non-admin kubeconfig authenticates via AAD exec plugin; kubelogin converts it to use the pipeline's service principal
# client-id/tenant-id must be passed as flags (kubelogin only bakes these into the kubeconfig from flags or pre-existing
# exec args, not from env vars); the secret is deliberately left out of the kubeconfig, read from AAD_SERVICE_PRINCIPAL_CLIENT_SECRET at token-fetch time
kubelogin convert-kubeconfig -l spn --client-id "${AAD_SERVICE_PRINCIPAL_CLIENT_ID}" --tenant-id "${tenantId}"