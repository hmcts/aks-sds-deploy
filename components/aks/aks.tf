resource "azurerm_resource_group" "kubernetes_resource_group" {
  for_each = toset([for k, v in var.clusters : k])
  location = var.location

  name = format("%s-%s-%s-rg",
    var.project,
    var.env,
    each.value
  )
  tags = module.ctags.common_tags
}

module "loganalytics" {
  source      = "git::https://github.com/hmcts/terraform-module-log-analytics-workspace-id.git?ref=master"
  environment = var.env
}

locals {
  linux_node_pool = {
    name                = "linux"
    vm_size             = lookup(var.linux_node_pool, "vm_size", "Standard_D4ds_v5")
    min_count           = lookup(var.linux_node_pool, "min_nodes", 2)
    max_count           = lookup(var.linux_node_pool, "max_nodes", 10)
    max_pods            = lookup(var.linux_node_pool, "max_pods", 30)
    os_type             = "Linux"
    node_taints         = []
    enable_auto_scaling = true
    mode                = "User"
    availability_zones  = var.availability_zones
  }

  system_node_pool = {
    name                = "msnode"
    vm_size             = lookup(var.windows_node_pool, "vm_size", "Standard_D4ds_v5")
    min_count           = lookup(var.windows_node_pool, "min_nodes", 2)
    max_count           = lookup(var.windows_node_pool, "max_nodes", 4)
    max_pods            = lookup(var.windows_node_pool, "max_pods", 30)
    os_type             = "Windows"
    node_taints         = ["kubernetes.io/os=windows:NoSchedule"]
    enable_auto_scaling = true
    mode                = "User"
    availability_zones  = var.availability_zones
  }
  cron_job_node_pool = {
    name                = "cronjob"
    vm_size             = "Standard_D4ds_v5"
    min_count           = 0
    max_count           = 10
    max_pods            = 30
    os_type             = "Linux"
    node_taints         = ["dedicated=jobs:NoSchedule"]
    enable_auto_scaling = true
    mode                = "User"
    availability_zones  = var.availability_zones
  }
}

data "azuread_service_principal" "version_checker" {
  display_name = "DTS SDS AKS version checker"
}

data "azuread_service_principal" "aks_auto_shutdown" {
  display_name = "DTS AKS Auto-Shutdown"
}

module "kubernetes" {
  for_each    = toset((var.env == "sbox" && var.cluster_automatic) ? [for k, v in var.clusters : k if k == "00"] : [for k, v in var.clusters : k])
  source      = "git::https://github.com/hmcts/aks-module-kubernetes.git?ref=4.x"
  environment = var.env
  location    = var.location

  kubelet_uami_enabled = true
  oms_agent_enabled    = var.oms_agent_enabled
  csi_driver_enabled   = tobool(lookup(var.clusters[each.value], "csi_driver_enabled", true))

  providers = {
    azurerm               = azurerm
    azurerm.hmcts-control = azurerm.hmcts-control
    azurerm.acr           = azurerm.acr
    azurerm.global_acr    = azurerm.global_acr
  }

  resource_group_name = azurerm_resource_group.kubernetes_resource_group[each.value].name

  network_name                = local.network_name
  network_shortname           = local.network_shortname
  network_resource_group_name = local.network_resource_group_name

  cluster_number    = each.value
  service_shortname = var.service_shortname
  project           = var.project

  ptl_cluster = var.ptl_cluster

  log_workspace_id                   = module.loganalytics.workspace_id
  monitor_diagnostic_setting         = var.monitor_diagnostic_setting
  monitor_diagnostic_setting_metrics = var.monitor_diagnostic_setting_metrics
  kube_audit_admin_logs_enabled      = var.kube_audit_admin_logs_enabled

  control_vault = var.control_vault

  kubernetes_cluster_ssh_key = var.kubernetes_cluster_ssh_key

  kubernetes_cluster_agent_min_count = lookup(var.system_node_pool, "min_nodes", 2)
  kubernetes_cluster_agent_max_count = lookup(var.system_node_pool, "max_nodes", 4)
  kubernetes_cluster_agent_vm_size   = lookup(var.system_node_pool, "vm_size", "Standard_D4ds_v5")

  kubernetes_cluster_version            = var.clusters[each.value]["kubernetes_version"]
  kubernetes_cluster_agent_os_disk_size = "128"

  tags     = module.ctags.common_tags
  sku_tier = var.sku_tier

  enable_user_system_nodepool_split = true

  additional_node_pools = contains(["ptlsbox", "ptl"], var.env) ? tolist([local.linux_node_pool, local.cron_job_node_pool]) : tolist([local.linux_node_pool, local.system_node_pool, local.cron_job_node_pool])

  availability_zones = var.availability_zones

  aks_version_checker_principal_id = data.azuread_service_principal.version_checker.object_id

  aks_role_definition = "Contributor"

  aks_auto_shutdown_principal_id = data.azuread_service_principal.aks_auto_shutdown.object_id

  enable_automatic_channel_upgrade_patch = var.enable_automatic_channel_upgrade_patch

  enable_node_os_channel_upgrade_nodeimage = true

  node_os_maintenance_window_config = var.node_os_maintenance_window_config
}

module "ctags" {
  source       = "git::https://github.com/hmcts/terraform-module-common-tags.git?ref=master"
  environment  = var.env
  product      = var.product
  builtFrom    = var.builtFrom
  autoShutdown = var.autoShutdown
  expiresAfter = var.expiresAfter
  startupMode  = var.startupMode
}


data "azurerm_resource_group" "mi_stg_rg" {
  count = local.is_dev ? 1 : 0

  provider = azurerm.dts-ss-stg
  name     = "managed-identities-stg-rg"

}

resource "azurerm_role_assignment" "dev_to_stg" {
  for_each = local.is_dev ? toset([for k, v in var.clusters : k]) : toset([])

  provider             = azurerm.dts-ss-stg
  role_definition_name = "Managed Identity Operator"
  principal_id         = module.kubernetes[each.key].kubelet_object_id
  scope                = data.azurerm_resource_group.mi_stg_rg[0].id
}

resource "null_resource" "register_automatic_sku_preview" {
  triggers = {
    cluster_creation = "${var.cluster_automatic ? 1 : 0}"
  }
}

resource "azapi_resource" "managedCluster" {

  count     = var.cluster_automatic ? 1 : 0
  type      = "Microsoft.ContainerService/managedClusters@2024-03-02-preview"
  parent_id = azurerm_resource_group.kubernetes_resource_group["01"].id
  name      = "ss-sbox-01-aks"
  location  = var.location

  identity {
    type = "SystemAssigned"
  }

  body = jsonencode({
    properties = {
      kubernetesVersion = "1.30.3"
      dnsPrefix         = "k8s-ss-sbox-aks"
      enableRBAC        = true
      servicePrincipalProfile = {
        clientId = "msi"
      }
      securityProfile = {
        workloadIdentity = {
          enabled = true
        }
        imageCleaner = {
          enabled       = true
          intervalHours = 168
        }
      }

      storageProfile = {
        diskCSIDriver = {
          enabled = true
          version = "v1"
        }
        fileCSIDriver = {
          enabled = true
        }
        snapshotController = {
          enabled = true
        }
      }
      aadProfile = {
        adminGroupObjectIDs = [
          "a6ce5b32-e0a5-419e-ba5c-67863c975941",
          "45bbf62b-788e-45e6-b584-01f62cf2d22a"
        ]
        clientAppID     = null
        enableAzureRBAC = true
        managed         = true
        serverAppID     = null
        serverAppSecret = null
        tenantID        = "531ff96d-0ae9-462a-8d2d-bec7c0b42082"
      }
      addonProfiles = {
        azureKeyvaultSecretsProvider = {
          config = {
            enableSecretRotation = "true"
            rotationPollInterval = "5m"
          }
          enabled = true
        }
      }
      agentPoolProfiles = [
        {
          count                  = 2
          enableEncryptionAtHost = false
          enableCustomCATrust    = false
          enableFIPS             = false
          enableNodePublicIP     = false
          enableUltraSSD         = false
          kubeletDiskType        = "OS"
          mode                   = "System"
          name                   = "system"
          nodeTaints             = ["CriticalAddonsOnly=true:NoSchedule"]
          osDiskSizeGB           = 128
          osDiskType             = "Ephemeral"
          osType                 = "Linux"
          tags = {
            application  = "core"
            autoShutdown = "true"
            builtFrom    = "hmcts/aks-sds-deploy"
            businessArea = "Cross-Cutting"
            criticality  = "Low"
            environment  = "sandbox"
            expiresAfter = "3000-01-01"
          }
          type   = "VirtualMachineScaleSets"
          vmSize = "Standard_D4ds_v5"
        },
        {
          count                  = 2
          enableEncryptionAtHost = false
          enableCustomCATrust    = false
          enableFIPS             = false
          enableNodePublicIP     = false
          enableUltraSSD         = false
          kubeletDiskType        = "OS"
          mode                   = "User"
          name                   = "linux"
          nodeTaints             = null
          osDiskSizeGB           = 128
          osDiskType             = "Ephemeral"
          osType                 = "Linux"
          tags = {
            application  = "core"
            autoShutdown = "true"
            builtFrom    = "hmcts/aks-sds-deploy"
            businessArea = "Cross-Cutting"
            criticality  = "Low"
            environment  = "sandbox"
            expiresAfter = "3000-01-01"
          }
          type   = "VirtualMachineScaleSets"
          vmSize = "Standard_D4ds_v5"
        },
        {
          count                  = 2
          enableEncryptionAtHost = false
          enableCustomCATrust    = false
          enableFIPS             = false
          enableNodePublicIP     = false
          enableUltraSSD         = false
          kubeletDiskType        = "OS"
          mode                   = "User"
          name                   = "cronjob"
          nodeTaints             = ["dedicated=jobs:NoSchedule"]
          osDiskSizeGB           = 128
          osDiskType             = "Ephemeral"
          osType                 = "Linux"
          tags = {
            application  = "core"
            autoShutdown = "true"
            builtFrom    = "hmcts/aks-sds-deploy"
            businessArea = "Cross-Cutting"
            criticality  = "Low"
            environment  = "sandbox"
            expiresAfter = "3000-01-01"
          }
          type   = "VirtualMachineScaleSets"
          vmSize = "Standard_D4ds_v5"
        }
      ]
      autoUpgradeProfile = {
        nodeOSUpgradeChannel = "NodeImage"
        upgradeChannel       = "rapid"
      }
    }
    sku = {
      name = "Automatic"
      tier = "Standard"
    }
  })
}

resource "azapi_resource" "service_operator_credential" {

  count                     = var.cluster_automatic ? 1 : 0
  schema_validation_enabled = false
  name                      = "ss-sbox-01-aks"
  parent_id                 = data.azurerm_user_assigned_identity.aks.id
  type                      = "Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2022-01-31-preview"
  location                  = var.location
  body = jsonencode({
    properties = {
      issuer = "https://uksouth.oic.prod-aks.azure.com/a8140a9e-f1b0-481f-a4de-09e2ee23f7ab/8c44a4cc-f514-43fc-bc82-da3bdd3dfacc"

      subject   = "system:serviceaccount:azureserviceoperator-system:azureserviceoperator-default"
      audiences = ["api://AzureADTokenExchange"]
    }
  })
  lifecycle {
    ignore_changes = [location]
  }
}
