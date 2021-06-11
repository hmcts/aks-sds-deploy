data "azurerm_subscription" "current" {}

data "azurerm_client_config" "current" {}

locals {
  slug_location = lower(replace(var.location, " ", "."))
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
  network_name = format("%s-%s-vnet",
    var.project,
    var.environment
  )
}



