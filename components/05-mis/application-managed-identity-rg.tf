resource "azurerm_resource_group" "application-mi" {
  name     = "managed-identities-${var.env}-rg"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_role_assignment" "uami_rg_identity_operator" {
  principal_id         = azurerm_user_assigned_identity.kubelet_uami.principal_id
  scope                = azurerm_resource_group.application-mi.id
  role_definition_name = "Managed Identity Operator"
}
