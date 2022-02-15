# General
variable "environment" {}

variable "project" {}

variable "product" {}

variable "cluster_count" {}
# Remote State
variable "control_vault" {}

variable "builtFrom" {}

variable "location" {
  default = "uksouth"
}

variable "service_shortname" {
  default = "aks"
}