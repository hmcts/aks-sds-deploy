data "azurerm_subscription" "current" {
}

data "azurerm_client_config" "current" {
}

data "azurerm_resource_group" "genesis_rg" {
  name = "genesis-rg"
}

data "azurerm_key_vault" "genesis_keyvault" {
  name                = "${lower(replace(data.azurerm_subscription.current.display_name, "-", ""))}kv"
  resource_group_name = data.azurerm_resource_group.genesis_rg.name
}

data "azurerm_resource_group" "acr_rg" {
  name = format("%s-acr-rg",
  local.acr[var.project].project,
  )
}