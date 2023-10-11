resource "azurerm_user_assigned_identity" "sops-mi" {
  resource_group_name = data.azurerm_resource_group.genesis_rg.name
  location            = data.azurerm_resource_group.genesis_rg.location

  name = "aks-${var.env}-mi"
  tags = local.common_tags
}

resource "azurerm_user_assigned_identity" "wi-admin-mi" {
  resource_group_name = azurerm_resource_group.application-mi.name
  location            = azurerm_resource_group.application-mi.location
  name                = "admin-${var.env}-mi"
  tags                = module.ctags.common_tags
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
    "Get",
    "Encrypt",
    "Decrypt",
    "List",
  ]

  secret_permissions = [
    "Get",
    "List",
  ]
}

resource "azurerm_role_assignment" "acme-vault-access" {
  scope                = data.azurerm_key_vault.acme.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.sops-mi.principal_id
}


locals {
  # Needed for role assignment only
  wi_environment_rg = var.env == "dev" ? "stg" : var.env
  # MIs for managed-identities-sbox-rg etc - for workload identity with ASO
  mi_sds = {
    # DTS-SHAREDSERVICES-SBOX
    sbox = {
      subscription_id = "a8140a9e-f1b0-481f-a4de-09e2ee23f7ab"
    }
    # DTS-SHAREDSERVICES-STG
    dev = {
      subscription_id = "74dacd4f-a248-45bb-a2f0-af700dc4cf68"
    }
    stg = {
      subscription_id = "74dacd4f-a248-45bb-a2f0-af700dc4cf689"
    }
    # DTS-SHAREDSERVICES-ITHC
    ithc = {
      subscription_id = "ba71a911-e0d6-4776-a1a6-079af1df7139"
    }
    # DTS-SHAREDSERVICES-TEST
    test = {
      subscription_id = "3eec5bde-7feb-4566-bfb6-805df6e10b90"
    }
    # DTS-SHAREDSERVICES-DEMO
    demo = {
      subscription_id = "c68a4bed-4c3d-4956-af51-4ae164c1957c"
    }
    # DTS-SHAREDSERVICES-PROD
    prod = {
      subscription_id = "5ca62022-6aa2-4cee-aaa7-e7536c8d566c"
    }
    # DTS-SHAREDSERVICESPTL-SBOX
    ptlsbox = {
      subscription_id = "64b1c6d6-1481-44ad-b620-d8fe26a2c768"
    }
    # DTS-SHAREDSERVICESPTL
    ptl = {
      subscription_id = "6c4d2513-a873-41b4-afdd-b05a33206631"
    }
  }
}

resource "azurerm_role_assignment" "externaldns-dns-zone-contributor" {
  for_each             = var.env == "dev" ? toset([azurerm_user_assigned_identity.sops-mi.principal_id, azurerm_user_assigned_identity.wi-admin-mi.principal_id]) : []
  scope                = "/subscriptions/1baf5470-1c3e-40d3-a6f7-74bfbce4b348/resourceGroups/core-infra-intsvc-rg/providers/Microsoft.Network/privateDnsZones/dev.platform.hmcts.net"
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = each.key
}

resource "azurerm_role_assignment" "externaldns-read-rg" {
  for_each             = var.env == "dev" ? toset([azurerm_user_assigned_identity.sops-mi.principal_id, azurerm_user_assigned_identity.wi-admin-mi.principal_id]) : []
  scope                = "/subscriptions/1baf5470-1c3e-40d3-a6f7-74bfbce4b348/resourceGroups/core-infra-intsvc-rg"
  role_definition_name = "Reader"
  principal_id         = each.key
}


resource "azurerm_role_assignment" "genesis_managed_identity_operator" {
  principal_id         = azurerm_user_assigned_identity.sops-mi.principal_id
  scope                = azurerm_user_assigned_identity.kubelet_uami.id
  role_definition_name = "Managed Identity Operator"
}

# Gives dev access to stg resource group
resource "azurerm_role_assignment" "service_operator_workload_identity" {
  count                = var.env == "dev" ? 1 : 0
  principal_id         = azurerm_user_assigned_identity.sops-mi.principal_id
  role_definition_name = "Contributor"
  scope                = "/subscriptions/${local.mi_sds[var.env].subscription_id}/resourceGroups/managed-identities-${local.wi_environment_rg}-rg"
}