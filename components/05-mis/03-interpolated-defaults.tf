data "azurerm_subscription" "current" {}

data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "genesis_rg" {
  name = "genesis-rg"
}

data "azurerm_resource_group" "platform-rg" {
  name = "sds-platform-${var.environment}-rg"
}

data "azurerm_key_vault" "genesis_keyvault" {
  name                = contains(["ptlsbox", "ptl"], var.environment) ? "dtssds${replace(var.environment, "-", "")}" : "${lower(replace(data.azurerm_subscription.current.display_name, "-", ""))}kv"
  resource_group_name = data.azurerm_resource_group.genesis_rg.name
}

data "azurerm_key_vault" "hmcts_access_vault" {
  provider            = azurerm.hmcts-control
  name                = var.control_vault
  resource_group_name = "azure-control-${var.environment}-rg"
}

data "azurerm_key_vault_secret" "kubernetes_cluster_client_id" {
  provider     = azurerm.hmcts-control
  name         = "sp-object-id"
  key_vault_id = data.azurerm_key_vault.hmcts_access_vault.id
}

data "azurerm_key_vault" "acme" {
  name = "acmedtssds${var.environment}"
  resource_group_name = data.azurerm_resource_group.platform-rg.name
}
