#!/bin/bash

# Generic query for name of clusters in subscription, checks for 00 and 01 and stores output in variable
cluster00="$(az aks list --output tsv --query '[].[name]' | grep 00 2>/dev/null)"
cluster01="$(az aks list --output tsv --query '[].[name]' | grep 01 2>/dev/null)"

# Check which values where found, if 00 and 01 then multiple clusters
# If 00 and not 01, single 00 cluster found
# If not 00 and 01, single 01 cluster found
# if neither 00 or 01, no clusters found
if [[ -n $cluster00 && -n $cluster01 ]]; then 
    echo "Found multiple clusters"
    output="All"
elif [[ -n $cluster00 && ! -n $cluster01 ]]; then
    echo "Found 00 cluster only"
    output="00"
elif [[ ! -n $cluster00 && -n $cluster01 ]]; then
    echo "Found 01 cluster only"
    output="01"
else 
    echo "Found no clusters"
    output="None"
fi

#Create pipeline variable for use later in script
echo "##vso[task.setvariable variable=cluster_deploy;isOutput=true]$output"
echo "After setting cluster_deploy"