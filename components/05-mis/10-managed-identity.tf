resource "azurerm_user_assigned_identity" "sops-mi" {
  resource_group_name = data.azurerm_resource_group.genesis_rg.name
  location            = data.azurerm_resource_group.genesis_rg.location

  name = "aks-${var.environment}-mi"
  tags = local.common_tags
}

resource "azurerm_role_assignment" "MI-Operator" {
  # DTS Bootstrap Principal_id
  principal_id         = azurerm_user_assigned_identity.sops-mi.principal_id
  role_definition_name = "Managed Identity Operator"
  scope                = azurerm_user_assigned_identity.sops-mi.id
}

resource "azurerm_role_assignment" "Reader" {
  # DTS Bootstrap Principal_id
  principal_id         = azurerm_user_assigned_identity.sops-mi.principal_id
  role_definition_name = "Reader"
  scope                = data.azurerm_key_vault.genesis_keyvault.id
}

resource "azurerm_key_vault_key" "sops-key" {
  name         = "sops-key"
  key_vault_id = data.azurerm_key_vault.genesis_keyvault.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
  ]
}

resource "azurerm_key_vault_access_policy" "sops-policy" {
  key_vault_id = data.azurerm_key_vault.genesis_keyvault.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = azurerm_user_assigned_identity.sops-mi.principal_id

  key_permissions = [
    "get",
    "encrypt",
    "decrypt",
    "list",
  ]

  secret_permissions = [
    "get",
    "list",
  ]
}

resource "azurerm_role_assignment" "acme-vault-access" {
  scope                = data.azurerm_key_vault.acme.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.sops-mi.principal_id
}


locals {
  external_dns = {
    # Resource Groups to add Reader permissions for external dns to
    resource_groups = toset([
      "/subscriptions/ed302caf-ec27-4c64-a05e-85731c3ce90e/resourceGroups/reformMgmtRG",
      "/subscriptions/1baf5470-1c3e-40d3-a6f7-74bfbce4b348/resourceGroups/core-infra-intsvc-rg"
    ])
    # Demo DNS zones to add "DNS Zone Contributor" premissions for external dns to
    demo = toset([
      "/subscriptions/ed302caf-ec27-4c64-a05e-85731c3ce90e/resourceGroups/reformMgmtRG/providers/Microsoft.Network/dnszones/demo.platform.hmcts.net",
      "/subscriptions/1baf5470-1c3e-40d3-a6f7-74bfbce4b348/resourceGroups/core-infra-intsvc-rg/providers/Microsoft.Network/privateDnsZones/demo.platform.hmcts.net"
    ])
  }
}

resource "azurerm_role_assignment" "externaldns-dns-zone-contributor" {
  for_each = lookup(local.external_dns, var.environment, toset([]))

  scope                = each.value
  role_definition_name = contains(regex("^.*/Microsoft.Network/(.*)/.*$", each.value), "privateDnsZones") ? "Private DNS Zone Contributor" : "DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.sops-mi.principal_id
}

resource "azurerm_role_assignment" "externaldns-read-rg" {
  # Only add the reader role if there are zones configured
  for_each = lookup(local.external_dns, var.environment, null) != null ? local.external_dns.resource_groups : toset([])

  scope                = each.value
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.sops-mi.principal_id
}

resource "azurerm_role_assignment" "genesis_managed_identity_operator" {
  principal_id         = azurerm_user_assigned_identity.kubelet_uami.principal_id
  scope                = data.azurerm_user_assigned_identity.kubelet_uami.id
  role_definition_name = "Managed Identity Operator"
}
