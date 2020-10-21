// HUB UK South

data "azurerm_virtual_network" "hub-south-vnet" {
  provider            = azurerm.hub
  name                = local.hub[var.hub].ukSouth.name
  resource_group_name = local.hub[var.hub].ukSouth.name
}

resource "azurerm_virtual_network_peering" "hub-south-to-spoke" {
  provider = azurerm.hub

  name = format("%s%s",
    var.project,
    var.environment
  )

  resource_group_name          = local.hub[var.hub].ukSouth.name
  virtual_network_name         = local.hub[var.hub].ukSouth.name
  remote_virtual_network_id    = module.network.network_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "spoke-to-hub-south" {
  name                         = "hubUkS"
  resource_group_name          = module.network.network_resource_group
  virtual_network_name         = module.network.network_name
  remote_virtual_network_id    = data.azurerm_virtual_network.hub-south-vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

// HUB UK West

data "azurerm_virtual_network" "hub-west-vnet" {
  provider            = azurerm.hub
  name                = local.hub[var.hub].ukWest.name
  resource_group_name = local.hub[var.hub].ukWest.name
}

resource "azurerm_virtual_network_peering" "hub-west-to-spoke" {
  provider = azurerm.hub

  name = format("%s%s",
    var.project,
    var.environment
  )

  resource_group_name       = local.hub[var.hub].ukWest.name
  virtual_network_name      = local.hub[var.hub].ukWest.name
  remote_virtual_network_id = module.network.network_id
}

resource "azurerm_virtual_network_peering" "spoke-to-hub-west" {
  name                         = "hubUkW"
  resource_group_name          = module.network.network_resource_group
  virtual_network_name         = module.network.network_name
  remote_virtual_network_id    = data.azurerm_virtual_network.hub-west-vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

// VPN

data "azurerm_virtual_network" "vpn" {
  provider            = azurerm.vpn
  name                = "core-infra-vnet-mgmt"
  resource_group_name = "rg-mgmt"
}

resource "azurerm_virtual_network_peering" "vpn-to-spoke" {
  provider = azurerm.vpn

  name = format("%s%s",
    var.project,
    var.environment
  )

  resource_group_name          = data.azurerm_virtual_network.vpn.resource_group_name
  virtual_network_name         = data.azurerm_virtual_network.vpn.name
  remote_virtual_network_id    = module.network.network_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "spoke-to-vpn" {
  name                         = "vpn"
  resource_group_name          = module.network.network_resource_group
  virtual_network_name         = module.network.network_name
  remote_virtual_network_id    = data.azurerm_virtual_network.vpn.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}
