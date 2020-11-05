resource "azurerm_user_assigned_identity" "sops-mi" {
  resource_group_name = data.azurerm_resource_group.genesis_rg.name
  location            = data.azurerm_resource_group.genesis_rg.location

  name = "aks-${var.environment}-mi"
  tags = local.common_tags
}

resource "azurerm_role_assignment" "MI-Operator" {
  # DTS Bootstrap Principal_id
  principal_id         = azurerm_user_assigned_identity.sops-mi.principal_id
  role_definition_name = "Managed Identity Operator"
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${data.azurerm_resource_group.genesis_rg.name}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/${azurerm_user_assigned_identity.sops-mi.name}"
}

resource "azurerm_role_assignment" "Reader" {
  # DTS Bootstrap Principal_id
  principal_id         = azurerm_user_assigned_identity.sops-mi.principal_id
  role_definition_name = "Reader"
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${data.azurerm_resource_group.genesis_rg.name}/providers/Microsoft.KeyVault/vaults/${data.azurerm_key_vault.genesis_keyvault.name}"
}

resource "azurerm_key_vault_key" "sops-key" {
  name         = "sops-key"
  key_vault_id = data.azurerm_key_vault.genesis_keyvault.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
  ]
}

resource "azurerm_key_vault_access_policy" "sops-policy" {
  key_vault_id = data.azurerm_key_vault.genesis_keyvault.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = azurerm_user_assigned_identity.sops-mi.principal_id

  key_permissions = [
    "get",
    "encrypt",
    "decrypt",
    "list",
  ]

  secret_permissions = [
    "get",
    "list",
  ]
}
