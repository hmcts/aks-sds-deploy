#!/usr/bin/env bash
set -e
az_keyvault_name="${4}"
AGENT_BUILDDIRECTORY=/tmp

if [ -f $AGENT_BUILDDIRECTORY/flux-ssh-git-key ]; then
    echo "Deleting SSH Private Key"
    rm -f $AGENT_BUILDDIRECTORY/flux-ssh-git-key
fi
if [ -f $AGENT_BUILDDIRECTORY/flux-ssh-git-key.pub ]; then
    echo "Deleting SSH Public Key"
    rm -f $AGENT_BUILDDIRECTORY/flux-ssh-git-key.pub
fi