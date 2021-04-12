resource "azurerm_resource_group" "kubernetes_resource_group" {
  location = var.location

  name = format("%s-%s-%s-rg",
    var.project,
    var.environment,
    var.cluster_number
  )
  tags = local.common_tags
}

module "loganalytics" {
  source      = "git::https://github.com/hmcts/terraform-module-log-analytics-workspace-id.git?ref=master"
  environment = var.environment
}

module "kubernetes" {
  source = "git::https://github.com/hmcts/aks-module-kubernetes.git?ref=windows-nodepool"

  environment = var.environment
  location    = var.location

  providers = {
    azurerm               = azurerm
    azurerm.hmcts-control = azurerm.hmcts-control
    azurerm.acr           = azurerm.acr
    azurerm.global_acr    = azurerm.global_acr
  }

  resource_group_name = azurerm_resource_group.kubernetes_resource_group.name

  network_name                = local.network_name
  network_shortname           = local.network_shortname
  network_resource_group_name = local.network_resource_group_name

  cluster_number    = var.cluster_number
  service_shortname = var.service_shortname
  project           = var.project

  log_workspace_id = module.loganalytics.workspace_id

  control_vault = var.control_vault

  kubernetes_cluster_ssh_key = var.kubernetes_cluster_ssh_key

  kubernetes_cluster_agent_min_count = var.kubernetes_cluster_agent_min_count
  kubernetes_cluster_agent_max_count = var.kubernetes_cluster_agent_max_count
  kubernetes_cluster_agent_vm_size   = var.kubernetes_cluster_agent_vm_size
  kubernetes_cluster_version         = var.kubernetes_cluster_version

  tags = local.common_tags

  additional_node_pools = [
    {
      name                = "msnode1"
      vm_size             = "Standard_DS3_v2"
      min_count           = 2
      max_count           = 5
      os_type             = "Windows"
      node_taints         = ["kubernetes.io/os=windows:NoSchedule"]
      enable_auto_scaling = true
    },
    {
      name                = "msnode2"
      vm_size             = "Standard_DS3_v2"
      min_count           = 2
      max_count           = 5
      os_type             = "Windows"
      node_taints         = ["kubernetes.io/os=windows:NoSchedule"]
      enable_auto_scaling = true
    }
  ]
}

