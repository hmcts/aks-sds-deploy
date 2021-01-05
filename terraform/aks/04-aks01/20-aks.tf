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
  source      = "../../../modules/loganalytics"
  environment = var.environment

}

data "azurerm_resource_group" "genesis_rg" {
  name = "genesis-rg"
}

data "azurerm_user_assigned_identity" "aks" {
  name                = "aks-${var.environment}-mi"
  resource_group_name = data.azurerm_resource_group.genesis_rg.name
}

module "kubernetes" {
  source = "git::https://github.com/hmcts/aks-module-kubernetes.git?ref=user-assigned-identity"

  environment = var.environment
  location    = var.location

  providers = {
    azurerm               = azurerm
    azurerm.hmcts-control = azurerm.hmcts-control
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

  tags                      = local.common_tags
  user_assigned_identity_id = data.azurerm_user_assigned_identity.aks.id
}
