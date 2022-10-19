#!/usr/bin/env bash

az aks get-versions --location uksouth --query 'orchestrators[?isPreview==null].orchestratorVersion' -o tsv | sort -r --version-sort | head -n 1
