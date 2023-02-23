#!/usr/bin/env bash
set -e

PARAM_LIST=( PROJECT SERVICE ENVIRONMENT KEYVAULT SUBSCRIPTION_NAME CLUSTER_NAMES COMMAND )
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

# Make sure the 7 arguments are passed
if [[ $# -lt 7 ]]
then
    usage
fi

echo "Params: $*"

project=${1}
env=${3}

if [[ "${6}" == "All" ]]; then
  echo "Checking for available clusters"
  clusters=$(az aks list --output tsv --query '[].name' | sed -n "s/${project}-${env}-\([0-9][0-9]\)-aks/\1/p")
  echo "Clusters found ${clusters}"
else
  clusters=${6}
fi

for cluster in ${clusters}; do
  set -- "${@:1:5}" "$cluster" "${@:7}"
  echo "Starting Deployment"
  ./get-aks-credentials.sh "$@" || error_exit "ERROR: Unable to get AKS credentials"
  ./create-sshkeys.sh "$@" || error_exit "ERROR: SSHKey Create Issues"
  ./apply-default-rbac.sh "$@" || error_exit "ERROR: Unable to set k8s RBAC"
  ./deploy-flux.sh "$@" || error_exit "ERROR: Unable to deploy Fluxcd"
  [[ $3 =~ ^(stg|prod)$ ]] && (./register-cluster-with-dynatrace.sh "$@" || error_exit "ERROR: Unable to register cluster with Dynatrace")
  echo "Cleanup"
  ./cleanup-sshkeys.sh "$@" || error_exit "ERROR: Unable to Cleanup"
  echo "Deployment Complete"
done