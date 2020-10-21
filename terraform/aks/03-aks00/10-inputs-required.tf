# General
variable "environment" {}

variable "project" {}

# Remote State
variable "control_vault" {}

# Service
variable "cluster_number" {}

# Kubernetes
variable "kubernetes_cluster_ssh_key" {}

variable "kubernetes_cluster_agent_min_count" {
  default = 1
}
variable "kubernetes_cluster_agent_max_count" {
  default = 3
}
variable "kubernetes_cluster_agent_vm_size" {
  default = "Standard_D4s_v3"
}

variable "kubernetes_cluster_version" {}
