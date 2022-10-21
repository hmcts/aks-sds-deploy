#!/usr/bin/env bash

aks_name=$1
aks_resource_group=$2
aks_subscription=$3

az aks get-upgrades \
    --name $aks_name \
    --resource-group $aks_resource_group \
    --subscription $aks_subscription \
    --query 'controlPlaneProfile.upgrades[?isPreview==null].kubernetesVersion' \
    --output tsv
