# data "azurerm_virtual_network" "initiator" {
#   provider            = azurerm.initiator
#   name                = var.initiator_vnet
#   resource_group_name = var.initiator_vnet_resource_group
#   depends_on = [module.network]
# }

# data "azurerm_virtual_network" "target" {
#   provider            = azurerm.target
#   name                = var.target_vnet
#   resource_group_name = var.target_vnet_resource_group
#   depends_on = [module.network]
# }