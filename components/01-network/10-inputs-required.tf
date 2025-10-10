# General
variable "env" {}

variable "builtFrom" {}

variable "product" {}

variable "enable_debug" {}

variable "control_vault" {}

variable "project" {}

variable "hub" {}

variable "private_dns_subscription" {}

variable "private_dns_zones" {}

# Network
variable "network_address_space" {}

variable "aks_00_subnet_cidr_blocks" {}

variable "aks_01_subnet_cidr_blocks" {}

variable "iaas_subnet_cidr_blocks" {}

variable "application_gateway_subnet_cidr_blocks" {}

variable "postgresql_subnet_cidr_blocks" {}

variable "postgresql_subnet_expanded_cidr_blocks" {}

variable "additional_routes_application_gateway" {
  default = []
}

variable "ingest_peering_config" {
  description = "Configuration for ingest peering connections"
  type = map(object({
    vnet_name      = string
    resource_group = string
    provider_alias = string
  }))
  default = {}
}
# Remote State
# variable "hmcts_access_vault" {}
# variable "remote_state_storage_account_name" {}

# Service
# variable "kubernetes_cluster_role_binding_groups" {
#   type = map(string)
#   default = {}
# }
