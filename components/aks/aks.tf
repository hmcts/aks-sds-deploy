resource "azurerm_resource_group" "kubernetes_resource_group" {
  for_each = toset([for k, v in var.clusters : k])
  location = var.location

  name = format("%s-%s-%s-rg",
    var.project,
    var.env,
    each.key
  )
  tags = module.ctags.common_tags
}

module "loganalytics" {
  source      = "git::https://github.com/hmcts/terraform-module-log-analytics-workspace-id.git?ref=master"
  environment = var.env
}

data "azuread_service_principal" "version_checker" {
  display_name = "DTS SDS AKS version checker"
}

data "azuread_service_principal" "aks_auto_shutdown" {
  display_name = "DTS AKS Auto-Shutdown"
}

module "kubernetes" {
  for_each    = var.env == "sbox" && var.cluster_automatic ? { for k, v in var.clusters : k => v if k == "00" } : var.clusters
  source      = "git::https://github.com/hmcts/aks-module-kubernetes.git?ref=4.x"
  environment = var.env
  location    = var.location

  kubelet_uami_enabled = true
  oms_agent_enabled    = var.oms_agent_enabled
  csi_driver_enabled   = var.csi_driver_enabled

  providers = {
    azurerm               = azurerm
    azurerm.hmcts-control = azurerm.hmcts-control
    azurerm.acr           = azurerm.acr
    azurerm.global_acr    = azurerm.global_acr
  }

  resource_group_name = azurerm_resource_group.kubernetes_resource_group[each.key].name

  network_name                = local.network_name
  network_shortname           = local.network_shortname
  network_resource_group_name = local.network_resource_group_name

  cluster_number    = each.key
  service_shortname = var.service_shortname
  project           = var.project

  ptl_cluster = var.ptl_cluster

  log_workspace_id                   = module.loganalytics.workspace_id
  monitor_diagnostic_setting         = var.monitor_diagnostic_setting
  monitor_diagnostic_setting_metrics = var.monitor_diagnostic_setting_metrics
  kube_audit_admin_logs_enabled      = var.kube_audit_admin_logs_enabled

  control_vault = var.control_vault

  kubernetes_cluster_ssh_key = each.value.kubernetes_cluster_ssh_key

  kubernetes_cluster_agent_min_count = lookup(each.value.system_node_pool, "min_nodes", 2)
  kubernetes_cluster_agent_max_count = lookup(each.value.system_node_pool, "max_nodes", 4)
  kubernetes_cluster_agent_vm_size   = lookup(each.value.system_node_pool, "vm_size", "Standard_D4ds_v5")

  kubernetes_cluster_version            = each.value.kubernetes_cluster_version
  kubernetes_cluster_agent_os_disk_size = "128"

  tags     = module.ctags.common_tags
  sku_tier = var.sku_tier

  enable_user_system_nodepool_split = true

  availability_zones = each.value.availability_zones

  aks_version_checker_principal_id = data.azuread_service_principal.version_checker.object_id

  aks_role_definition = "Contributor"

  aks_auto_shutdown_principal_id = data.azuread_service_principal.aks_auto_shutdown.object_id

  enable_automatic_channel_upgrade_patch = each.value.enable_automatic_channel_upgrade_patch

  enable_node_os_channel_upgrade_nodeimage = true

  node_os_maintenance_window_config = each.value.node_os_maintenance_window_config

  additional_node_pools = contains(["ptlsbox", "ptl", "sbox", "test"], var.env) ? tolist([
    {
      name                = "linux"
      vm_size             = lookup(each.value.linux_node_pool, "vm_size", "Standard_D4ds_v5")
      min_count           = lookup(each.value.linux_node_pool, "min_nodes", 2)
      max_count           = lookup(each.value.linux_node_pool, "max_nodes", 10)
      max_pods            = lookup(each.value.linux_node_pool, "max_pods", 30)
      os_type             = "Linux"
      os_sku              = null
      node_taints         = []
      enable_auto_scaling = true
      mode                = "User"
    },
    {
      name                = "cronjob"
      vm_size             = "Standard_D4ds_v5"
      min_count           = 0
      max_count           = 10
      max_pods            = 30
      os_type             = "Linux"
      os_sku              = null
      node_taints         = ["dedicated=jobs:NoSchedule"]
      enable_auto_scaling = true
      mode                = "User"
    }
    ]) : tolist([
    {
      name                = "linux"
      vm_size             = lookup(each.value.linux_node_pool, "vm_size", "Standard_D4ds_v5")
      min_count           = lookup(each.value.linux_node_pool, "min_nodes", 2)
      max_count           = lookup(each.value.linux_node_pool, "max_nodes", 10)
      max_pods            = lookup(each.value.linux_node_pool, "max_pods", 30)
      os_type             = "Linux"
      os_sku              = null
      node_taints         = []
      enable_auto_scaling = true
      mode                = "User"
    },
    {
      name                = "msnode"
      vm_size             = each.value.windows_node_pool.vm_size
      min_count           = each.value.windows_node_pool.min_nodes
      max_count           = each.value.windows_node_pool.max_nodes
      max_pods            = each.value.windows_node_pool.max_pods
      os_type             = "Windows"
      os_sku              = each.value.windows_node_pool.os_sku
      node_taints         = ["kubernetes.io/os=windows:NoSchedule"]
      enable_auto_scaling = true
      mode                = "User"
    },
    {
      name                = "cronjob"
      vm_size             = "Standard_D4ds_v5"
      min_count           = 0
      max_count           = 10
      max_pods            = 30
      os_type             = "Linux"
      os_sku              = null
      node_taints         = ["dedicated=jobs:NoSchedule"]
      enable_auto_scaling = true
      mode                = "User"
    }
  ])
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
