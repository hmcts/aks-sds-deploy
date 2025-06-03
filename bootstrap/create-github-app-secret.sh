#!/usr/bin/env bash
set -e

az_keyvault_name="${4}"
AGENT_BUILDDIRECTORY=/tmp

flux_github_app_id="$(az keyvault secret list --vault-name ${az_keyvault_name} --query "[?name=='flux-github-app-id'].name" -o tsv)"
flux_github_app_installation_id="$(az keyvault secret list --vault-name ${az_keyvault_name} --query "[?name=='flux-github-app-installation-id'].name" -o tsv)"
flux_github_app_private_key="$(az keyvault secret list --vault-name ${az_keyvault_name} --query "[?name=='flux-github-app-priv-key'].name" -o tsv)"
if [[ -z $flux_github_app_id ]] || [[ -z $flux_github_app_installation_id ]] || [[ -z $flux_github_app_private_key ]]
    then
            echo "GitHub App secrets not found in Key Vault, please ensure GitHub App secrets for this environment are set in its Key Vault"
            exit 1
    else
            echo "Flux GitHub App secrets Download"
            az keyvault secret download --name flux-github-app-id --vault-name ${az_keyvault_name} --file $AGENT_BUILDDIRECTORY/flux-github-app-id --encoding ascii
            az keyvault secret download --name flux-github-app-installation-id --vault-name ${az_keyvault_name} --file $AGENT_BUILDDIRECTORY/flux-github-app-installation-id --encoding ascii
            az keyvault secret download --name flux-github-app-priv-key --vault-name ${az_keyvault_name} --file $AGENT_BUILDDIRECTORY/flux-github-app-private-key --encoding ascii
    fi
