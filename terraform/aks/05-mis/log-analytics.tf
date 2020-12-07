

resource "azurerm_role_assignment" "log_analytics_role_MI" {

  provider = azurerm.log_analytics
  principal_id                    = azurerm_user_assigned_identity.sops-mi.principal_id
  role_definition_name            = "Log Analytics Contributor"
  scope                           = module.loganalytics.workspace_id
}


resource "azurerm_role_assignment" "log_analytics_role_aks_sp" {
  # AKS SP ACR Pull role
  provider = azurerm.log_analytics
  role_definition_name             = "Log Analytics Contributor"
  principal_id                     = data.azurerm_key_vault_secret.kubernetes_cluster_client_id.value
  scope                            = module.loganalytics.workspace_id
}



module "loganalytics" {
  source = "../../../modules/loganalytics"
  environment = var.environment


}

