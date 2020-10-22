resource "azurerm_resource_group" "acr_resource_group" {
  location = var.location

  name = format("%s-acr-rg",
    var.project
  )
  tags = local.common_tags
}


#--------------------------------------------------------------
# Public Azure Container Registry
#--------------------------------------------------------------

resource "azurerm_container_registry" "container_registry" {
  name                = format("%shmctspublic",
    var.project,
    var.type
  )
  resource_group_name = azurerm_resource_group.acr_resource_group.name
  location            = var.location
  admin_enabled       = "true"
  sku                 = "Premium"

  tags = local.common_tags

}

#--------------------------------------------------------------
# Private Azure Container Registry
#--------------------------------------------------------------

resource "azurerm_container_registry" "container_registry" {
  name                = format("%shmctsprivate",
    var.project,
    var.type
  )
  resource_group_name = azurerm_resource_group.acr_resource_group.name
  location            = var.location
  admin_enabled       = "true"
  sku                 = "Premium"

  tags = local.common_tags

}
