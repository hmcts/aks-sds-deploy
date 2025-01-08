#!/usr/bin/env bash
set -e

az_keyvault_name="${controlKeyVault}"
AGENT_BUILDDIRECTORY=/tmp


var_exist="$(az keyvault secret list --vault-name ${az_keyvault_name} --query "[?name=='flux-ssh-git-key-private'].name" -o tsv)"
if test -z "$var_exist"
    then
            echo "SSHKey Setup"
            ssh-keygen -t ed25519 -f $AGENT_BUILDDIRECTORY/flux-ssh-git-key -q -P "" -C ""
            az keyvault secret set --name flux-ssh-git-key-private --vault-name ${az_keyvault_name} --file $AGENT_BUILDDIRECTORY/flux-ssh-git-key
            az keyvault secret set --name flux-ssh-git-key-public --vault-name ${az_keyvault_name} --file $AGENT_BUILDDIRECTORY/flux-ssh-git-key.pub
    else
            echo "SSHKey Download"
            az keyvault secret download --name flux-ssh-git-key-private --vault-name ${az_keyvault_name} --file $AGENT_BUILDDIRECTORY/flux-ssh-git-key --encoding ascii
            az keyvault secret download --name flux-ssh-git-key-public --vault-name ${az_keyvault_name} --file $AGENT_BUILDDIRECTORY/flux-ssh-git-key.pub --encoding ascii
    fi
