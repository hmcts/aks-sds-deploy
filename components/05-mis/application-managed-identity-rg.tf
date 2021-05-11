resource "azurerm_resource_group" "application-mi" {
  name     = "managed-identities-${var.environment}-rg"
  location = var.location
  tags     = local.common_tags
}
