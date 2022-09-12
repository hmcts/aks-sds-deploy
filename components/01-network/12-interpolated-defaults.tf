data "azurerm_subscription" "current" {}

data "azurerm_client_config" "current" {}

data "azurerm_virtual_network" "vpn" {
  provider            = azurerm.vpn
  name                = "core-infra-vnet-mgmt"
  resource_group_name = "rg-mgmt"
}

locals {
  network_resource_group_name = format("%s-%s-network-rg",
    var.project,
    var.environment
  )
  network_shortname = format("%s_%s",
    var.project,
    var.service_shortname
  )
}



