resource "azurerm_user_assigned_identity" "kubelet_uami" {
  name = "aks-kubelet-${var.environment}-mi"

  resource_group_name = data.azurerm_resource_group.genesis_rg.name
  location            = data.azurerm_resource_group.genesis_rg.location
  tags                = local.common_tags
}

data "azurerm_user_assigned_identity" "aks" {
  name                = "aks-${var.environment}-mi"
  resource_group_name = data.azurerm_resource_group.genesis_rg.name
}

data "azurerm_resource_group" "node_resource_group" {
  name = azurerm_kubernetes_cluster.kubernetes_cluster.node_resource_group
}

data "azurerm_resource_group" "managed-identity-operator" {
  name = "managed-identities-${var.environment}-rg"
}

resource "azurerm_role_assignment" "sbox_registry_acrpull" {
  for_each = local.is_sbox ? toset(["sbox"]) : toset([])
  provider             = azurerm.sds_sbox_acr
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.kubelet_uami.principal_id
  scope                = data.azurerm_resource_group.sds_sbox_acr[0].id
}