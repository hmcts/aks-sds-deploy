variable "application_name" {
  default = "flux"
}

variable "location" {
  default = "UK South"
}

locals {
  // TODO delete after applying MI in all ENVs
  // working around 'Error: Provider configuration not present'
  acr = {
    ss = {
      subscription = "5ca62022-6aa2-4cee-aaa7-e7536c8d566c"
      project      = "sds"
    }
    sds_sbox = {
      subscription = "a8140a9e-f1b0-481f-a4de-09e2ee23f7ab"
    }
  }
  is_sbox = var.environment == "sbox" ? true : false

  common_tags = module.ctags.common_tags

  log_analytics_env_mapping = {
    sandbox = ["sbox", "ptlsbox"]
    nonprod = ["dev", "test", "ithc", "demo", "stg"]
    prod    = ["prod", "mgmt", "ptl"]
  }

  log_analytics_workspace = {
    sandbox = {
      subscription_id = "bf308a5c-0624-4334-8ff8-8dca9fd43783"
      name            = "hmcts-sandbox"
    }
    nonprod = {
      subscription_id = "1c4f0704-a29e-403d-b719-b90c34ef14c9"
      name            = "hmcts-nonprod"
    }
    prod = {
      subscription_id = "8999dec3-0104-4a27-94ee-6588559729d1"
      name            = "hmcts-prod"
    }
  }
  log_analytics_subscription_id = local.log_analytics_workspace[[for x in keys(local.log_analytics_env_mapping) : x if contains(local.log_analytics_env_mapping[x], var.environment)][0]].subscription_id
  resolved_name                 = local.log_analytics_workspace[[for x in keys(local.log_analytics_env_mapping) : x if contains(local.log_analytics_env_mapping[x], var.environment)][0]].name

  network_name = format("%s-%s-vnet",
  var.project,
  var.environment
  )
  network_shortname = format("%s_%s",
  var.project,
  var.service_shortname
  )
  network_resource_group_name = format("%s-%s-network-rg",
  var.project,
  var.environment
  )
}

module "ctags" {
  source      = "git::https://github.com/hmcts/terraform-module-common-tags.git?ref=master"
  environment = var.environment
  product     = var.product
  builtFrom   = var.builtFrom
}

module "kubernetes" {
  for_each    = toset(var.clusters)
  source      = "git::https://github.com/hmcts/aks-module-kubernetes.git?ref=DTSPO-7031"
  environment = var.environment
  location    = var.location
  kubelet_uami_enabled = true

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

  kubernetes_cluster_version            = var.kubernetes_cluster_version
  kubernetes_cluster_agent_os_disk_size = "128"

  tags     = module.ctags.common_tags
  sku_tier = var.sku_tier

  enable_user_system_nodepool_split = true

  additional_node_pools = contains(["ptlsbox", "ptl"], var.environment) ? tolist([local.linux_node_pool]) : tolist([local.linux_node_pool, local.system_node_pool])

  depends_on         = [azurerm_resource_group.disks_resource_group]
  availability_zones = var.availability_zones
}