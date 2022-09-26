resource "azurerm_resource_group" "kubernetes_resource_group" {
  for_each = toset([for k, v in var.clusters : k])
  location = var.location

  name = format("%s-%s-%s-rg",
    var.project,
    var.environment,
    each.value
  )
  tags = module.ctags.common_tags
}

resource "azurerm_resource_group" "disks_resource_group" {
  location = var.location
  name     = "disks-${var.environment}-rg"
  tags     = module.ctags.common_tags
}

module "loganalytics" {
  source      = "git::https://github.com/hmcts/terraform-module-log-analytics-workspace-id.git?ref=master"
  environment = var.environment
}

locals {
  linux_node_pool = {
    name                = "linux"
    vm_size             = lookup(var.linux_node_pool, "vm_size", "Standard_DS3_v2")
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
    vm_size             = lookup(var.windows_node_pool, "vm_size", "Standard_DS3_v2")
    min_count           = lookup(var.windows_node_pool, "min_nodes", 2)
    max_count           = lookup(var.windows_node_pool, "max_nodes", 4)
    max_pods            = lookup(var.windows_node_pool, "max_pods", 30)
    os_type             = "Windows"
    node_taints         = ["kubernetes.io/os=windows:NoSchedule"]
    enable_auto_scaling = true
    mode                = "User"
    availability_zones  = var.availability_zones
  }
}


module "kubernetes" {
  for_each    = toset([for k, v in var.clusters : k])
  source      = "git::https://github.com/hmcts/aks-module-kubernetes.git?ref=DTSPO-10279_auto_channel_updates"
  environment = var.environment
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

  log_workspace_id = module.loganalytics.workspace_id

  control_vault = var.control_vault

  kubernetes_cluster_ssh_key = var.kubernetes_cluster_ssh_key

  kubernetes_cluster_agent_min_count = lookup(var.system_node_pool, "min_nodes", 2)
  kubernetes_cluster_agent_max_count = lookup(var.system_node_pool, "max_nodes", 4)
  kubernetes_cluster_agent_vm_size   = lookup(var.system_node_pool, "vm_size", "Standard_DS3_v2")

  kubernetes_cluster_version            = var.clusters[each.value]["kubernetes_version"]
  kubernetes_cluster_agent_os_disk_size = "128"

  tags     = module.ctags.common_tags
  sku_tier = var.sku_tier

  enable_user_system_nodepool_split = true

  additional_node_pools = contains(["ptlsbox", "ptl"], var.environment) ? tolist([local.linux_node_pool]) : tolist([local.linux_node_pool, local.system_node_pool])

  depends_on         = [azurerm_resource_group.disks_resource_group]
  availability_zones = var.availability_zones

  enable_automatic_channel_upgrade_patch = var.enable_automatic_channel_upgrade_patch
}

module "ctags" {
  source      = "git::https://github.com/hmcts/terraform-module-common-tags.git?ref=master"
  environment = var.environment
  product     = var.product
  builtFrom   = var.builtFrom
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
