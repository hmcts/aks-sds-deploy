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
  clusters=$(az aks list --output tsv --query '[].name')
  echo -e "Clusters found:\n${clusters}"
  cluster_numbers=$(echo "${clusters}" |sed -n "s/${project}-${env}-\([0-9][0-9]\)-aks/\1/p" )
else
  cluster_numbers=${6}
fi

for cluster in ${cluster_numbers}; do
  set -- "${@:1:5}" "$cluster" "${@:7}"
  echo "################################"
  echo -e "Starting Deployment on ${project}-${env}-${cluster}-aks\n"
  ./aks-sds-deploy/bootstrap/get-aks-credentials.sh "$@" || error_exit "ERROR: Unable to get AKS credentials"
  ./aks-sds-deploy/bootstrap/create-sshkeys.sh "$@" || error_exit "ERROR: SSHKey Create Issues"
  ./aks-sds-deploy/bootstrap/apply-default-rbac.sh "$@" || error_exit "ERROR: Unable to set k8s RBAC"
  ./aks-sds-deploy/bootstrap/deploy-flux.sh "$@" || error_exit "ERROR: Unable to deploy Fluxcd"
  echo "Cleanup"
  ./aks-sds-deploy/bootstrap/cleanup-sshkeys.sh "$@" || error_exit "ERROR: Unable to Cleanup"
  echo "Deployment Complete for ${project}-${env}-${cluster}-aks"
  echo -e "################################\n\n\n"
done
