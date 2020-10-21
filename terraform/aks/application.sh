#!/usr/bin/env bash

. _application_cmds

set -o errexit
set -o nounset
PARAM_LIST=( SERVICE ENVIRONMENT LOCATION TFSTATESTORAGE COMMAND )

function usage() {
    echo ""
    echo "$0 ${PARAM_LIST[*]} [EXTRA_TERRAFORM_PARAMS]"
    echo ""
    echo service: "$SERVICES"
    echo location: "Deployment location"
    echo tfstatestorage: "$TFSTATESTORAGE"
    echo command: "$COMMANDS"
    echo ""
    exit 0
}

if [[ $# -lt 5 ]]
then
    usage
fi

for param in "${PARAM_LIST[@]}"; do
    printf -v "$param" "$1" && shift
done

$COMMAND "$@"