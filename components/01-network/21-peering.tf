# HUB

module "vnet_peer_hub_prod" {
  source = "github.com/hmcts/terraform-module-vnet-peering"

  for_each = toset([for r in local.regions : r if contains(local.hub_to_env_mapping["prod"], var.env)])
  peerings = {
    source = {
      name           = (var.env == "ptl") || (var.env == "dev") ? "${local.hub["prod"][each.key].peering_name}-prod" : local.hub["prod"][each.key].peering_name
      vnet           = module.network.network_name
      resource_group = module.network.network_resource_group
    }
    target = {
      name           = format("%s%s", var.project, var.env)
      vnet           = local.hub["prod"][each.key].name
      resource_group = local.hub["prod"][each.key].name
    }
  }
  providers = {
    azurerm.initiator = azurerm
    azurerm.target    = azurerm.hub-prod
  }
}

module "vnet_peer_hub_nonprod" {
  source = "github.com/hmcts/terraform-module-vnet-peering"

  for_each = toset([for r in ["ukSouth"] : r if contains(local.hub_to_env_mapping["nonprod"], var.env)])
  peerings = {
    source = {
      name           = var.env == "ptl" ? "${local.hub["prod"][each.key].peering_name}-nonprod" : var.env == "stg" ? "${local.hub["prod"][each.key].peering_name}-nonprod" : local.hub["prod"][each.key].peering_name
      vnet           = module.network.network_name
      resource_group = module.network.network_resource_group
    }
    target = {
      name           = format("%s%s", var.project, var.env)
      vnet           = local.hub["nonprod"][each.key].name
      resource_group = local.hub["nonprod"][each.key].name
    }
  }

  providers = {
    azurerm.initiator = azurerm
    azurerm.target    = azurerm.hub-nonprod
  }
}

module "vnet_peer_hub_sbox" {
  source = "github.com/hmcts/terraform-module-vnet-peering"

  for_each = toset([for r in ["ukSouth"] : r if contains(local.hub_to_env_mapping["sbox"], var.env)])
  peerings = {
    source = {
      name           = var.env == "ptl" ? "${local.hub["prod"][each.key].peering_name}-sbox" : local.hub["prod"][each.key].peering_name
      vnet           = module.network.network_name
      resource_group = module.network.network_resource_group
    }
    target = {
      name           = format("%s%s", var.project, var.env)
      vnet           = local.hub["sbox"][each.key].name
      resource_group = local.hub["sbox"][each.key].name
    }
  }

  providers = {
    azurerm.initiator = azurerm
    azurerm.target    = azurerm.hub-sbox
  }
}

# VPN

module "vnet_peer_vpn" {
  source = "github.com/hmcts/terraform-module-vnet-peering"
  peerings = {
    source = {
      name           = "vpn"
      vnet           = module.network.network_name
      resource_group = module.network.network_resource_group
    }
    target = {
      name           = format("%s%s", var.project, var.env)
      vnet           = data.azurerm_virtual_network.vpn.name
      resource_group = data.azurerm_virtual_network.vpn.resource_group_name
    }
  }

  providers = {
    azurerm.initiator = azurerm
    azurerm.target    = azurerm.vpn
  }
}
