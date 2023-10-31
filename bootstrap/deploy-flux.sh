#!/usr/bin/env bash
set -e

############################################################
ENVIRONMENT="${3}"
CLUSTER_NAME="${6}"
AGENT_BUILDDIRECTORY=/tmp
KUSTOMIZE_VERSION=4.5.7
############################################################
# Functions
############################################################

function flux_v2_ssh_git_key {
    ssh-keyscan -t ecdsa-sha2-nistp256 github.com > $AGENT_BUILDDIRECTORY/known_hosts
    echo " Kubectl Create Secret"
    kubectl create secret generic git-credentials \
    --from-file=identity=$AGENT_BUILDDIRECTORY/flux-ssh-git-key \
    --from-file=identity.pub=$AGENT_BUILDDIRECTORY/flux-ssh-git-key.pub \
    --from-file=known_hosts=$AGENT_BUILDDIRECTORY/known_hosts \
    --namespace flux-system \
    --dry-run=client -o yaml > "${TMP_DIR}/gotk/git-credentials.yaml"
}

############################################################
# End of functions
############################################################

TMP_DIR=/tmp/flux/${ENVIRONMENT}/${CLUSTER_NAME}
mkdir -p "${TMP_DIR}"/{gotk,flux-config}

flux_v2_ssh_git_key

 Cleanup
rm -rf "${TMP_DIR}"
