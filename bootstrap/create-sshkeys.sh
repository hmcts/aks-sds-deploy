#!/usr/bin/env bash
set -e

az_keyvault_name="${4}"
AGENT_BUILDDIRECTORY=/tmp


var_exist="$(az keyvault secret show --vault-name ${az_keyvault_name} --name 'flux-ssh-git-key-private' --query value -o tsv)"
if test -z "$var_exist"
    then
            echo "SSHKey Setup"
            ssh-keygen -t rsa -f $AGENT_BUILDDIRECTORY/flux-ssh-git-key -q -P "" -C ""
            az keyvault secret set --name flux-ssh-git-key-private --vault-name ${az_keyvault_name} --file $AGENT_BUILDDIRECTORY/flux-ssh-git-key
            az keyvault secret set --name flux-ssh-git-key-public --vault-name ${az_keyvault_name} --file $AGENT_BUILDDIRECTORY/flux-ssh-git-key.pub
            rm -f $AGENT_BUILDDIRECTORY/flux-ssh-git-key*
    else
            echo "SSHKey Download"
            az keyvault secret download --name flux-ssh-git-key-private --vault-name ${az_keyvault_name} --file $AGENT_BUILDDIRECTORY/flux-ssh-git-key --encoding ascii
            az keyvault secret download --name flux-ssh-git-key-public --vault-name ${az_keyvault_name} --file $AGENT_BUILDDIRECTORY/flux-ssh-git-key.pub --encoding ascii
    fi
