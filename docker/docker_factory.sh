#!/usr/bin/env bash

. _docker_cmds

set -o errexit
set -o nounset
PARAM_LIST=( DOCKER_IMAGE_NAME DOCKER_IMAGE_TAG DOCKER_REPOSITORY COMMAND )

function usage() {
    echo "$0 ${PARAM_LIST[*]} [EXTRA_DOCKER_PARAMS]"
    echo ""
    echo docker_image_name: "Docker image name"
    echo docker_image_tag: "Docker image tag"
    echo docker_repository: "Docker ACR to push image to"
    echo commands: "$COMMANDS"
    exit 0
}

if [[ $# -lt 4 ]]
then
    usage
fi

for param in "${PARAM_LIST[@]}"; do
    printf -v "$param" "$1" && shift
done

$COMMAND "$@"