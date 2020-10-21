#!/usr/bin/env bash

az_keyvault_name="$1"
secret_name="$2"
secret_value="$3"
tags="Created_By="Bootstrap""

function usage {
    echo "KeyVault Pusher usage:"
    echo "$0 keyvault_name 'secert-name1;secret-name2' 'secert-value1;secret-value2'"
    echo ""
    exit 0
}

if [[ $# != 3 ]]; then
    usage
fi

if [ -z "${secret_name}" ] || [ -z "${secret_value}" ]; then
    usage
fi

IFS="; " read -r -a array_sn <<< "$secret_name"
IFS="; " read -r -a array_sv <<< "$secret_value"

element_count_sn=${#array_sn[*]}
element_count_sv=${#array_sv[*]}

if [ ${element_count_sn} -ne ${element_count_sv} ]; then
    echo "ERROR: Supplied number of secret names does not match number of values! Exiting..."
    echo "ERROR: There are ${element_count_sn} secret names and ${element_count_sv} secret values! Stopping..."
    exit 1
fi

function main {
    local index=0
    while [ "$index" -lt "$element_count_sn" ];do   
        _azkv_secret_set ${array_sn[$index]} ${array_sv[$index]}
        let "index = $index + 1"
    done
}

function _azkv_secret_set {
   az keyvault secret set \
    --vault-name ${az_keyvault_name} \
    --name ${1} \
    --value ${2} \
    --tag $tags
    if [[ $? != 0 ]]; then
        echo "ERROR: Unable to set secret "${2}". Stopping..."
        exit 1
    fi
}

main