resource "azurerm_user_assigned_identity" "kubelet_uami" {
  name = "aks-kubelet-${var.environment}-mi"

  resource_group_name = data.azurerm_resource_group.genesis_rg.name
  location            = data.azurerm_resource_group.genesis_rg.location
  tags                = local.common_tags
}

resource "azurerm_role_assignment" "sbox_registry_acrpull" {
  for_each = local.is_sbox ? toset(["sbox"]) : toset([])
  provider             = azurerm.sds_sbox_acr
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.kubelet_uami.principal_id
  scope                = data.azurerm_resource_group.sds_sbox_acr[0].id
}


resource "azurerm_role_assignment" "genesis_managed_identity_operator" {
  principal_id         = data.azurerm_kubernetes_cluster.kubernetes_cluster.kubelet_identity[0].object_id
  scope                = data.azurerm_user_assigned_identity.aks.id
  role_definition_name = "Managed Identity Operator"
}

resource "azurerm_role_assignment" "uami_rg_identity_operator" {
  principal_id         = data.azurerm_kubernetes_cluster.kubernetes_cluster.kubelet_identity[0].object_id
  scope                = data.azurerm_resource_group.managed-identity-operator.id
  role_definition_name = "Managed Identity Operator"
}

resource "azurerm_role_assignment" "node_infrastructure_update_scale_set" {
  principal_id         = data.azurerm_kubernetes_cluster.kubernetes_cluster.kubelet_identity[0].object_id
  scope                = data.azurerm_resource_group.node_resource_group.id
  role_definition_name = "Virtual Machine Contributor"
}