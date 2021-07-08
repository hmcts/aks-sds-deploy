resource "azurerm_virtual_network_peering" "initiator-To-target" {
  provider = azurerm.initiator

  name                         = var.initiator_peer_name
  resource_group_name          = var.initiator_vnet_resource_group
  virtual_network_name         = var.initiator_vnet
  remote_virtual_network_id    = data.azurerm_virtual_network.target.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

}

resource "azurerm_virtual_network_peering" "target-To-initiator" {
  provider = azurerm.target

  name                         = var.target_peer_name
  resource_group_name          = var.target_vnet_resource_group
  virtual_network_name         = var.target_vnet
  remote_virtual_network_id    = data.azurerm_virtual_network.initiator.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

}