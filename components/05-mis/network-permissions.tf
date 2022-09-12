data "azurerm_virtual_network" "network" {
  name = format("%s-%s-vnet",
    var.project,
    var.environment
  )
  resource_group_name = format("%s-%s-network-rg",
    var.project,
    var.environment
  )
}

resource "azurerm_role_assignment" "network_access" {
  principal_id         = azurerm_user_assigned_identity.sops-mi.principal_id
  role_definition_name = "Network Contributor"
  scope                = data.azurerm_virtual_network.network.id
}
