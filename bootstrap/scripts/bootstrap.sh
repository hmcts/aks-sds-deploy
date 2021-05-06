#!/usr/bin/env bash
set -e

PARAM_LIST=( PROJECT SERVICE ENVIRONMENT KEYVAULT SUBSCRIPTION_NAME CLUSTER_NAME COMMAND )
############################################################
# Functions
############################################################

function usage() {
    echo ""
    echo "$0 ${PARAM_LIST[*]}"
    exit 0
}

function error_exit {
	echo "$1" 1>&2
  echo "Stopping..."
  #cleanup
	exit 1
}

############################################################

# Make sure they 7 arguments are passed
if [[ $# -lt 7 ]]
then
    usage
fi


echo "Starting Deployment"
bash get-aks-credentials.sh "$@" || error_exit "ERROR: Unable to get AKS credentials"
bash create-sshkeys.sh "$@" || error_exit "ERROR: SSHKey Create Issues"
bash apply-default-rbac.sh "$@" || error_exit "ERROR: Unable to set k8s RBAC"
bash deploy-flux.sh "$@" || error_exit "ERROR: Unable to deploy Fluxcd"
echo "Cleanup"
bash cleanup-sshkeys.sh "$@" || error_exit "ERROR: Unable to Cleanup"
echo "Deployment Complete"