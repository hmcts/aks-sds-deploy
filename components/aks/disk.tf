# TODO this file would be better in the MI component but that would require a lot of state migration
resource "azurerm_resource_group" "disks_resource_group" {
  location = var.location
  name     = "disks-${var.env}-rg"
  tags     = module.ctags.common_tags
}

resource "azurerm_role_assignment" "disk" {
  principal_id         = data.azurerm_user_assigned_identity.aks.principal_id
  role_definition_name = "Virtual Machine Contributor"
  scope                = azurerm_resource_group.disks_resource_group.id
}
