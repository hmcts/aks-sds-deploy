#!/usr/bin/env bash
set -e
az_keyvault_name="${4}"

echo "Applying Default Rbac"
cat ../../kubernetes/rbac/default-rbac.yaml | \
sed -e 's@${CLUSTER_READ_ONLY_GROUP}@'"$(az keyvault secret show --vault-name ${az_keyvault_name}  --name 'aks-user-rbac-group-id' --query 'value' -o tsv)"'@'  | \
        kubectl apply -f -
