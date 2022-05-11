provider "azurerm" {
  subscription_id            = "8999dec3-0104-4a27-94ee-6588559729d1"
  skip_provider_registration = "true"
  features {}
  alias = "global_acr"
}

data "azurerm_resource_group" "global_acr" {
  provider = azurerm.global_acr
  name     = "rpe-acr-prod-rg"
}

resource "azurerm_role_assignment" "global_registry_acrpull" {
  provider = azurerm.global_acr

  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.kubelet_uami.principal_id
  scope                = data.azurerm_resource_group.global_acr.id
}

data "azurerm_resource_group" "project_acr" {
  provider = azurerm.acr
  name     = "sds-acr-rg"
}

resource "azurerm_role_assignment" "project_registry_acrpull" {
  provider = azurerm.acr

  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.kubelet_uami.principal_id
  scope                = data.azurerm_resource_group.project_acr.id
}
