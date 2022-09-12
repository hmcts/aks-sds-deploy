resource "azurerm_user_assigned_identity" "kubelet_uami" {
  name = "aks-kubelet-${var.environment}-mi"

  resource_group_name = data.azurerm_resource_group.genesis_rg.name
  location            = data.azurerm_resource_group.genesis_rg.location
  tags                = local.common_tags
}

resource "azurerm_role_assignment" "sbox_registry_acrpull" {
  for_each             = local.is_sbox ? toset(["sbox"]) : toset([])
  provider             = azurerm.sds_sbox_acr
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.kubelet_uami.principal_id
  scope                = data.azurerm_resource_group.sds_sbox_acr[0].id
}

resource "azurerm_role_assignment" "kubelet_uami_genesis" {
  # DTS Bootstrap Principal_id
  principal_id         = azurerm_user_assigned_identity.kubelet_uami.principal_id
  role_definition_name = "Managed Identity Operator"
  scope                = azurerm_user_assigned_identity.sops-mi.id
}
