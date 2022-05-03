output "mi_client_id" {
  value = azurerm_user_assigned_identity.sops-mi.client_id
}

output "mi_id" {
  value = azurerm_user_assigned_identity.sops-mi.id
}

output "mi_principal_id" {
  value = azurerm_user_assigned_identity.sops-mi.principal_id
}
