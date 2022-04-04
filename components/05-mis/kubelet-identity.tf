resource "azurerm_role_assignment" "Kubelet-MI" {
  name = "aks-kubelet-${var.environment}-mi"
  principal_id         = azurerm_user_assigned_identity.sops-mi.principal_id
  role_definition_name = "Managed Identity Operator"
  scope                = azurerm_user_assigned_identity.sops-mi.id
}
