variable "environment" {}

variable "project" {}

variable "control_vault" {}

variable "builtFrom" {}

variable "product" {}

variable "clusters" {
  type        = list(string)
  description = "List of clusters to manage e.g [\"00\", \"01\"] "
  default     = []
}

variable "service_shortname" {
  default = "aks"
}

variable "kubernetes_cluster_ssh_key" {}

variable "kubernetes_cluster_version" {}

variable "availability_zones" {
  type = list(any)
}