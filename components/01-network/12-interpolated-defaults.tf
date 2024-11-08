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
    var.env
  )
  network_shortname = format("%s_%s",
    var.project,
    var.service_shortname
  )
  pinned_aks_routes_exists   = "${path.cwd}../../environments/01-network/${var.env}-pinned-aks-routes.yaml"
  pinned_appgw_routes_exists = "${path.cwd}../../environments/01-network/${var.env}-pinned-appgw-routes.yaml"
  pinned_aks_routes_yaml     = fileexists(local.pinned_aks_routes_exists) ? yamldecode(file(local.pinned_aks_routes_exists)) : {}
  pinned_appgw_routes_yaml   = fileexists(local.pinned_appgw_routes_exists) ? yamldecode(file(local.pinned_appgw_routes_exists)) : {}
  pinned_aks_routes = flatten([
    for key, value in local.pinned_aks_routes_yaml : {
      name                   = key
      address_prefix         = value.address_prefix
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = value.next_hop_address
    }
  ])
  pinned_appgw_routes = flatten([
    for key, value in local.pinned_appgw_routes_yaml : {
      name                   = key
      address_prefix         = value.address_prefix
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = value.next_hop_address
    }
  ])
}



