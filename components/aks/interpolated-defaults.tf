data "azurerm_subscription" "current" {}

data "azurerm_client_config" "current" {}

locals {
  slug_location = lower(replace(var.location, " ", "."))
}

locals {
  network_resource_group_name = format("%s-%s-network-rg",
    var.project,
    var.env
  )
  network_shortname = format("%s_%s",
    var.project,
    var.service_shortname
  )
  network_name = format("%s-%s-vnet",
    var.project,
    var.env
  )
}

data "azurerm_resource_group" "genesis_rg" {
  name = "genesis-rg"
}

data "azurerm_user_assigned_identity" "aks" {
  name                = "aks-${var.env}-mi"
  resource_group_name = data.azurerm_resource_group.genesis_rg.name
}

locals {
  # Build Windows node pool configuration with defaults for each cluster
  windows_node_pool = {
    for cluster_key, cluster_config in var.clusters : cluster_key => merge(
      {
        vm_size   = "Standard_D4ds_v5"
        min_nodes = 2
        max_nodes = 4
        max_pods  = 30
        os_sku    = null
      },
      cluster_config.windows_node_pool != null ? cluster_config.windows_node_pool : {}
    )
  }
}

