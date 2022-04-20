resource "azurerm_resource_group" "application-mi" {
  name     = "managed-identities-${var.environment}-rg"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_role_assignment" "uami_rg_identity_operator" {
  principal_id         = module.kubernetes.kubelet_object_id
  scope                = azurerm_resource_group.application-mi.id
  role_definition_name = "Managed Identity Operator"
}
