data "azurerm_virtual_network" "network" {
  name = format("%s-%s-vnet",
    var.project,
    var.env
  )
  resource_group_name = format("%s-%s-network-rg",
    var.project,
    var.env
  )
}

resource "azurerm_role_assignment" "network_access" {
  principal_id         = azurerm_user_assigned_identity.sops-mi.principal_id
  role_definition_name = "Network Contributor"
  scope                = data.azurerm_virtual_network.network.id
}

resource "azurerm_role_assignment" "private_dns_vnet_join_access" {
  count = contains(keys(local.private_dns_vnet_link_principal_ids_by_env), var.env) ? 1 : 0

  principal_id         = local.private_dns_vnet_link_principal_ids_by_env[var.env]
  role_definition_name = "Network Contributor"
  scope                = data.azurerm_virtual_network.network.id
}
