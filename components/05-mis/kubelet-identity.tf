resource "azurerm_role_assignment" "Kubelet-MI" {
  name                 = "aks-kubelet-${var.environment}-mi"
  principal_id         = azurerm_user_assigned_identity.sops-mi.principal_id
  role_definition_name = "Managed Identity Operator"
  scope                = azurerm_user_assigned_identity.sops-mi.id
}

resource "azurerm_role_assignment" "sbox_registry_acrpull" {
  name                 = "aks-kubelet-sbox-mi"
  for_each = local.is_sbox ? toset(var.clusters) : toset([])
  provider             = azurerm.sds_sbox_acr
  role_definition_name = "AcrPull"
  principal_id         = data.azurerm_role_assignment.Kubelet-MI.id
  scope                = data.azurerm_resource_group.sds_sbox_acr[0].id
}
