

resource "azurerm_role_assignment" "acrpull_role_MI" {
  principal_id                    = azurerm_user_assigned_identity.sops-mi.principal_id
  role_definition_name            = "AcrPull"
  scope                           = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${data.azurerm_resource_group.acr_rg.name}"
}


resource "azurerm_role_assignment" "acrpull_role_aks_sp" {
  # AKS SP ACR Pull role
  role_definition_name             = "AcrPull"
  principal_id                     = data.azurerm_client_config.current.client_id
  scope                            = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${data.azurerm_resource_group.acr_rg.name}"
  #skip_service_principal_aad_check = true
}
