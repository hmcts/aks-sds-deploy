# RBAC

Azure Kubernetes Service (AKS) can be configured to use Azure Active Directory (AD) for user authentication.
This allows a user log into an AKS cluster using your Azure Active Directory authentication token. Additionally, 
cluster administrators are able to configure Kubernetes role-based access control (RBAC) based on a users identity or directory group membership.

To integrate AD with AKS, we need to create 2 items;

- [Server Application](https://docs.microsoft.com/en-us/azure/aks/aad-integration#create-server-application)
- [Client Application](https://docs.microsoft.com/en-us/azure/aks/aad-integration#create-client-application)

The steps in the link above should be done by a GA. Once completed you should have;

- server-app-id
- server-app-secret
- client-app-id
- tenant-id

Save the above to an Azure Key Vault accessible to Terraform during the deployment of the AKS cluster with specified names in the code snippet below.

```
data "azurerm_key_vault_secret" "kubernetes_aad_client_app_id" {
  name      = "kubernetes-aad-client-app-id"
  vault_uri = "https://${var.hmcts_access_vault}.vault.azure.net/"
}

data "azurerm_key_vault_secret" "kubernetes_aad_tenant_id" {
  name      = "kubernetes-aad-tenant-id"
  vault_uri = "https://${var.hmcts_access_vault}.vault.azure.net/"
}

data "azurerm_key_vault_secret" "kubernetes_aad_server_app_id" {
  name      = "kubernetes-aad-server-app-id"
  vault_uri = "https://${var.hmcts_access_vault}.vault.azure.net/"
}

data "azurerm_key_vault_secret" "kubernetes_aad_server_app_secret" {
  name      = "kubernetes-aad-server-app-secret"
  vault_uri = "https://${var.hmcts_access_vault}.vault.azure.net/"
}
```

Once the cluster has been created by Terraform, it can only be accessed using a Service Principal. To loging to the cluster using `kubectl` after it's been created;

```
$ az aks get-credentials --resource-group $CLUSTER_RESOURCE_GROUP_NAME --name $CLUSTER_NAME --admin
```

We can now grant additional AD objects access to the cluster by creating `ClusterRoleBinding` specify either **Groups** or **Users**.

```
group-rbac.yaml

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
 name: ssaks-cluster-admins
roleRef:
 apiGroup: rbac.authorization.k8s.io
 kind: ClusterRole
 name: cluster-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
```

```
$ kubectl create -f group-rbac.yaml
```

Now members of that group will be able to login to the cluster to run `kubectl` commands.

```
$ az login
$ az aks get-credentials --resource-group $CLUSTER_RESOURCE_GROUP_NAME --name $CLUSTER_NAME
```
