data "azurerm_subscription" "current" {}

data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "genesis_rg" {
  name = "genesis-rg"
}

data "azurerm_resource_group" "platform-rg" {
  name = "sds-platform-${var.env}-rg"
}

data "azurerm_resource_group" "sds_sbox_acr" {
  provider = azurerm.sds_sbox_acr
  name     = "sds-acr-rg"

  count = local.is_sbox ? 1 : 0
}

data "azurerm_key_vault" "genesis_keyvault" {
  name                = contains(["ptlsbox", "ptl"], var.env) ? "dtssds${replace(var.env, "-", "")}" : "${lower(replace(data.azurerm_subscription.current.display_name, "-", ""))}kv"
  resource_group_name = data.azurerm_resource_group.genesis_rg.name
}

data "azurerm_key_vault" "hmcts_access_vault" {
  provider            = azurerm.hmcts-control
  name                = var.control_vault
  resource_group_name = "azure-control-${var.env}-rg"
}

data "azurerm_key_vault_secret" "kubernetes_cluster_client_id" {
  provider     = azurerm.hmcts-control
  name         = "sp-object-id"
  key_vault_id = data.azurerm_key_vault.hmcts_access_vault.id
}

data "azurerm_key_vault" "acme" {
  name                = "acmedtssds${var.env}"
  resource_group_name = data.azurerm_resource_group.platform-rg.name
}


data "azurerm_key_vault" "acme_dev" {
  name                = "acmedtssdsdev"
  resource_group_name = data.azurerm_resource_group.platform-rg.name
}