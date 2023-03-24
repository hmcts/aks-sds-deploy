# General
variable "env" {}

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
  default = "Standard_D4ds_v5"
}

variable "availability_zones" {
  type = list(any)
}

variable "clusters" {
  type        = map(map(string))
  description = <<-EOF
Map of clusters to manage. Example:
clusters = {
  "00" = {
    kubernetes_version = "1.22.6"
  },
  "01" = {
    kubernetes_version = "1.22.6"
  }
}
EOF
}
