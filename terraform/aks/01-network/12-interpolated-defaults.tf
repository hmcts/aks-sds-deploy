data "azurerm_subscription" "current" {}

data "azurerm_client_config" "current" {}

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



