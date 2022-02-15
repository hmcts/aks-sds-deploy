# General
variable "environment" {}

variable "project" {}

variable "product" {}

variable "cluster_count" {}
# Remote State
variable "control_vault" {}

variable "service_shortname" {
  default = "aks"
}