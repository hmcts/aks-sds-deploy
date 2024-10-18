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
  source      = "git::https://github.com/hmcts/aks-module-kubernetes.git?ref=master"
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

  provisioner "local-exec" {
    command = <<EOT
      az extension add --name aks-preview || az extension update --name aks-preview
      az feature register --namespace Microsoft.ContainerService --name EnableAPIServerVnetIntegrationPreview
      az feature register --namespace Microsoft.ContainerService --name NRGLockdownPreview
      az feature register --namespace Microsoft.ContainerService --name SafeguardsPreview
      az feature register --namespace Microsoft.ContainerService --name NodeAutoProvisioningPreview
      az feature register --namespace Microsoft.ContainerService --name DisableSSHPreview
      az feature register --namespace Microsoft.ContainerService --name AutomaticSKUPreview

      # Wait for all features to be registered
      for feature in EnableAPIServerVnetIntegrationPreview NRGLockdownPreview SafeguardsPreview NodeAutoProvisioningPreview DisableSSHPreview AutomaticSKUPreview; do
        while [ "$(az feature show --namespace Microsoft.ContainerService --name $feature --query properties.state -o tsv)" != "Registered" ]; do
          echo "Waiting for $feature feature to be registered..."
          sleep 10
        done
      done

      # Register the provider
      az provider register --namespace Microsoft.ContainerService
    EOT
  }
}

resource "azapi_resource" "managedCluster" {
  depends_on = [null_resource.register_automatic_sku_preview]

  count     = var.cluster_automatic ? 1 : 0
  type      = "Microsoft.ContainerService/managedClusters@2024-03-02-preview"
  parent_id = azurerm_resource_group.kubernetes_resource_group["01"].id
  name      = "ss-sbox-01-aks"
  location  = var.location

  identity {
    type         = "UserAssigned"
    identity_ids = ["/subscriptions/a8140a9e-f1b0-481f-a4de-09e2ee23f7ab/resourceGroups/genesis-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/aks-sbox-mi"]
  }

  body = ({
    properties = {
      kubernetesVersion = "1.30.3"
      dnsPrefix         = "k8s-ss-sbox-aks"
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
      networkProfile = {
        networkPlugin    = "azure"
        networkDataplane = "azure"
        ipFamilies = [
          "IPv4"
        ]
        dnsServiceIP    = "10.0.0.10"
        serviceCidr     = "10.0.0.0/16"
        loadBalancerSku = "Standard"
        outboundType    = "loadBalancer"
        loadBalancerSku = "Standard"
        loadBalancerProfile = {
          allocatedOutboundPorts = null
          backendPoolType        = "nodeIPConfiguration"
          effectiveOutboundIPs = [
            {
              id            = "/subscriptions/a8140a9e-f1b0-481f-a4de-09e2ee23f7ab/resourceGroups/ss-sbox-01-aks-node-rg/providers/Microsoft.Network/publicIPAddresses/1926b15c-3b71-4dea-8336-e0441c593a5a"
              resourceGroup = "ss-sbox-01-aks-node-rg"
            }
          ]
          enableMultipleStandardLoadBalancers = null
          idleTimeoutInMinutes                = null
          managedOutboundIPs = {
            count     = 1
            countIpv6 = null
          }
          outboundIPs        = null
          outboundIpPrefixes = null
        }
      }
      agentPoolProfiles = [
        {
          availabilityZones = ["1"]
          count             = 2
          enableAutoScaling = true
          maxCount          = 4
          minCount          = 2
          mode              = "System"
          name              = "system"
          nodeTaints        = ["CriticalAddonsOnly=true:NoSchedule"]
          osDiskSizeGB      = 128
          osDiskType        = "Ephemeral"
          osType            = "Linux"
          tags = {
            application  = "core"
            autoShutdown = "true"
            builtFrom    = "hmcts/aks-sds-deploy"
            businessArea = "Cross-Cutting"
            criticality  = "Low"
            environment  = "sandbox"
            expiresAfter = "3000-01-01"
          }
          type         = "VirtualMachineScaleSets"
          vmSize       = "Standard_D4ds_v5"
          vnetSubnetID = "/subscriptions/a8140a9e-f1b0-481f-a4de-09e2ee23f7ab/resourceGroups/ss-sbox-network-rg/providers/Microsoft.Network/virtualNetworks/ss-sbox-vnet/subnets/aks-01"
        },
        {
          availabilityZones = ["1"]
          count             = 2
          enableAutoScaling = true
          maxCount          = 4
          minCount          = 2
          mode              = "User"
          name              = "linux"
          nodeTaints        = null
          osDiskSizeGB      = 128
          osDiskType        = "Ephemeral"
          osType            = "Linux"
          tags = {
            application  = "core"
            autoShutdown = "true"
            builtFrom    = "hmcts/aks-sds-deploy"
            businessArea = "Cross-Cutting"
            criticality  = "Low"
            environment  = "sandbox"
            expiresAfter = "3000-01-01"
          }
          type         = "VirtualMachineScaleSets"
          vmSize       = "Standard_D4ds_v5"
          vnetSubnetID = "/subscriptions/a8140a9e-f1b0-481f-a4de-09e2ee23f7ab/resourceGroups/ss-sbox-network-rg/providers/Microsoft.Network/virtualNetworks/ss-sbox-vnet/subnets/aks-01"
        },
        {
          availabilityZones = ["1"]
          count             = 0
          enableAutoScaling = true
          maxCount          = 10
          minCount          = 0
          mode              = "User"
          name              = "cronjob"
          nodeTaints        = ["dedicated=jobs:NoSchedule"]
          osDiskSizeGB      = 128
          osDiskType        = "Ephemeral"
          osType            = "Linux"
          tags = {
            application  = "core"
            autoShutdown = "true"
            builtFrom    = "hmcts/aks-sds-deploy"
            businessArea = "Cross-Cutting"
            criticality  = "Low"
            environment  = "sandbox"
            expiresAfter = "3000-01-01"
          }
          type         = "VirtualMachineScaleSets"
          vmSize       = "Standard_D4ds_v5"
          vnetSubnetID = "/subscriptions/a8140a9e-f1b0-481f-a4de-09e2ee23f7ab/resourceGroups/ss-sbox-network-rg/providers/Microsoft.Network/virtualNetworks/ss-sbox-vnet/subnets/aks-01"
        }
      ]
      autoScalerProfile = {
        balance-similar-node-groups           = "false"
        daemonset-eviction-for-empty-nodes    = false
        daemonset-eviction-for-occupied-nodes = true
        expander                              = "random"
        ignore-daemonsets-utilization         = false
        max-empty-bulk-delete                 = "10"
        max-graceful-termination-sec          = "600"
        max-node-provision-time               = "15m"
        max-total-unready-percentage          = "45"
        new-pod-scale-up-delay                = "0s"
        ok-total-unready-count                = "3"
        scale-down-delay-after-add            = "10m"
        scale-down-delay-after-delete         = "10s"
        scale-down-delay-after-failure        = "3m"
        scale-down-unneeded-time              = "10m"
        scale-down-unready-time               = "20m"
        scale-down-utilization-threshold      = "0.5"
        scan-interval                         = "10s"
        skip-nodes-with-local-storage         = "false"
        skip-nodes-with-system-pods           = "true"
      }
    }
    sku = {
      name = "Automatic"
      tier = "Standard"
    }
  })
}
