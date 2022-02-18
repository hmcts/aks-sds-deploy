# General
variable "environment" {}

variable "project" {}

variable "builtFrom" {}

variable "product" {}

# Remote State
variable "control_vault" {}

# Kubernetes
variable "kubernetes_cluster_ssh_key" {}

variable "kubernetes_cluster_agent_min_count" {
  default = 1
}
variable "kubernetes_cluster_agent_max_count" {
  default = 3
}
variable "kubernetes_cluster_agent_vm_size" {
  default = "Standard_DS3_v2"
}

variable "kubernetes_cluster_version" {}

variable "cluster_count" {}

variable "availability_zones" {
  type = list(any)
}

variable "clusters" {
  type        = list(string)
  description = "List of clusters to manage e.g [\"00\", \"01\"] "
  default     = []
}
