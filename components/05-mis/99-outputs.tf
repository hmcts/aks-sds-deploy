output "mi_client_id" {
  value = azurerm_user_assigned_identity.sops-mi.client_id
}

output "mi_id" {
  value = azurerm_user_assigned_identity.sops-mi.id
}

output "mi_principal_id" {
  value = azurerm_user_assigned_identity.sops-mi.principal_id
}

// output "kubelet_uami_client_id" {
//   value = azurerm_user_assigned_identity.kubelet_uami.client_id
// }

// output "kubelet_uami_id" {
//   value = azurerm_user_assigned_identity.kubelet_uami.id
// }

// output "kubelet_uami_principal_id" {
//   value = azurerm_user_assigned_identity.kubelet_uami.principal_id
// }
