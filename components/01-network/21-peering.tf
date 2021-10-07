# HUB

module "vnet_peer_hub_prod" {
  source = "../../modules/vnet_peering"

  for_each = toset([for r in local.regions : r if contains(local.hub_to_env_mapping["prod"], var.environment)])

  initiator_peer_name = (var.environment == "ptl") || (var.environment == "dev") ? "${local.hub["prod"][each.key].peering_name}-prod" : local.hub["prod"][each.key].peering_name

  target_peer_name = format("%s%s",
    var.project,
    var.environment
  )
  initiator_vnet                = module.network.network_name
  initiator_vnet_resource_group = module.network.network_resource_group
  initiator_vnet_subscription   = var.subscription_id

  target_vnet                = local.hub["prod"][each.key].name
  target_vnet_resource_group = local.hub["prod"][each.key].name
  target_vnet_subscription   = local.hub["prod"].subscription

  providers = {
    azurerm.initiator = azurerm
    azurerm.target    = azurerm.hub-prod
  }
}

module "vnet_peer_hub_nonprod" {
  source = "../../modules/vnet_peering"

  for_each = toset([for r in local.regions : r if contains(local.hub_to_env_mapping["nonprod"], var.environment)])

  initiator_peer_name = var.environment == "ptl" ? "${local.hub["prod"][each.key].peering_name}-nonprod" : local.hub["prod"][each.key].peering_name

  target_peer_name = format("%s%s",
    var.project,
    var.environment
  )

  initiator_vnet                = module.network.network_name
  initiator_vnet_resource_group = module.network.network_resource_group
  initiator_vnet_subscription   = var.subscription_id

  target_vnet                = local.hub["nonprod"][each.key].name
  target_vnet_resource_group = local.hub["nonprod"][each.key].name
  target_vnet_subscription   = local.hub["nonprod"].subscription

  providers = {
    azurerm.initiator = azurerm
    azurerm.target    = azurerm.hub-nonprod
  }
}

module "vnet_peer_hub_sbox" {
  source = "../../modules/vnet_peering"

  for_each = toset([for r in local.regions : r if contains(local.hub_to_env_mapping["sbox"], var.environment)])

  initiator_peer_name = var.environment == "ptl" ? "${local.hub["prod"][each.key].peering_name}-sbox" : local.hub["prod"][each.key].peering_name

  target_peer_name = format("%s%s",
    var.project,
    var.environment
  )

  initiator_vnet                = module.network.network_name
  initiator_vnet_resource_group = module.network.network_resource_group
  initiator_vnet_subscription   = var.subscription_id

  target_vnet                = local.hub["sbox"][each.key].name
  target_vnet_resource_group = local.hub["sbox"][each.key].name
  target_vnet_subscription   = local.hub["sbox"].subscription

  providers = {
    azurerm.initiator = azurerm
    azurerm.target    = azurerm.hub-sbox
  }
}

# VPN

module "vnet_peer_vpn" {
  source = "../../modules/vnet_peering"

  initiator_peer_name = "vpn"

  target_peer_name = format("%s%s",
    var.project,
    var.environment
  )

  initiator_vnet                = module.network.network_name
  initiator_vnet_resource_group = module.network.network_resource_group
  initiator_vnet_subscription   = var.subscription_id

  target_vnet                = data.azurerm_virtual_network.vpn.name
  target_vnet_resource_group = data.azurerm_virtual_network.vpn.resource_group_name
  target_vnet_subscription   = "ed302caf-ec27-4c64-a05e-85731c3ce90e"

  providers = {
    azurerm.initiator = azurerm
    azurerm.target    = azurerm.vpn
  }
}
