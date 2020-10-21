
resource "azurerm_private_dns_zone_virtual_network_link" "link" {
  for_each = toset(var.private_dns_zones)

  provider = azurerm.private-dns
  name = format("%s%s",
    var.project,
    var.environment
  )
  resource_group_name   = "core-infra-intsvc-rg"
  private_dns_zone_name = each.key
  virtual_network_id    = module.network.network_id
}
