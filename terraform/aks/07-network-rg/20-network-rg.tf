resource "azurerm_resource_group" "network_resource_group" {
  location = var.location

  name = format("%s-%s-network-rg",
    var.project,
    var.environment
  )
  tags = local.common_tags
}


