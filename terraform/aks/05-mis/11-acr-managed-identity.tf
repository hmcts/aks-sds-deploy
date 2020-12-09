

resource "azurerm_role_assignment" "acrpull_role_MI" {
  provider             = azurerm.acr
  principal_id         = azurerm_user_assigned_identity.sops-mi.principal_id
  role_definition_name = "AcrPull"
  scope                = data.azurerm_resource_group.acr_rg.id
}


resource "azurerm_role_assignment" "acrpull_role_aks_sp" {
  # AKS SP ACR Pull role
  provider             = azurerm.acr
  role_definition_name = "AcrPush"
  principal_id         = data.azurerm_key_vault_secret.kubernetes_cluster_client_id.value
  scope                = data.azurerm_resource_group.acr_rg.id
}
