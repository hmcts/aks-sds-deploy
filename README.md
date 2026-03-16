# aks-sds-deploy

Terraform code to deploy Shared Services AKS Cluster and underlying infrastructure.

## Warning

When merging to this repo please check your plans for AKS version changes.

If you see a change similar to 1.34.X -> 1.34 this will bring the cluster into a failed state when applied as it rebuilds the nodes and the PDBs in the cluster will block this.

When applying with a change like this in the plan you will need to delete the PDBs with allowed disruptions set to 0 from the cluster as it applies.

## Following resources are being deployed in each stage of the pipeline

    1) Genesis
        a) Creates a resource group called "genesis-rg"
        b) Creates a KV and update access policy
        
    2) Network
        a) Creates a resource group
        b) Creates Vnet, subnets & route tables
        c) Peers with hub and vpn vnets
        d) Updates private DNS
        
    3) AKS00
        a) Builds AKS cluster with default linux node pool
        b) Adds additional windows node pool

    3) AKS01
        a) Builds AKS cluster with default linux node pool
        b) Adds additional windows node pool
        
    4) Bootstrap
        a) Creates sshkeys for flux if required
        b) Implements RBAC
        c) Install flux and helm operator
