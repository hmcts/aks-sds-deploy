#!/usr/bin/env bash

. _bootstrap_cmds

set -o errexit
set -o nounset
PARAM_LIST=( PROJECT SERVICE ENVIRONMENT KEYVAULT SUBSCRIPTION_NAME CLUSTER_NAME COMMAND )

function usage() {
    echo ""
    echo "$0 ${PARAM_LIST[*]}"
    echo ""
    echo command: "$COMMANDS"
    echo ""
    exit 0
}

if [[ $# -lt 7 ]]
then
    usage
fi

for param in "${PARAM_LIST[@]}"; do
    printf -v "$param" "$1" && shift
done

$COMMAND "$@"