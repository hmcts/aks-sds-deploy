# General
variable "env" {}

variable "project" {}

variable "builtFrom" {}

variable "product" {}

# # Remote State
variable "control_vault" {}

# Kubernetes
variable "clusters" {
  description = <<-EOF
    Map of clusters to manage. Example:
    clusters = {
      "00" = {
        kubernetes_cluster_version = "1.22.6"
        kubernetes_cluster_ssh_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCe..."
        enable_automatic_channel_upgrade_patch = true

        system_node_pool = {
          vm_size   = "Standard_D4ds_v5"
          min_nodes = 2
          max_nodes = 4
        }

        linux_node_pool = {
          vm_size   = "Standard_D4ds_v5"
          min_nodes = 4
          max_nodes = 10
        }

        windows_node_pool = {
          vm_size   = "Standard_D4ds_v5"
          min_nodes = 2
          max_nodes = 4
        }

        availability_zones = ["1"]
        autoShutdown       = true

        node_os_maintenance_window_config = {
          frequency  = "Daily"
          start_time = "16:00"
          is_prod    = false
        }
      },
      "01" = {
        kubernetes_cluster_version = "1.30"
        kubernetes_cluster_ssh_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCe..."
        enable_automatic_channel_upgrade_patch = true

        system_node_pool = {
          min_nodes = 2
          max_nodes = 4
        }

        linux_node_pool = {
          vm_size   = "Standard_D4ds_v5"
          max_nodes = 10
          max_nodes = 10
        }

        availability_zones = ["1"]
        autoShutdown       = true

        node_os_maintenance_window_config = {
          frequency  = "Daily"
          start_time = "16:00"
          is_prod    = false
        }
      }
    }
  EOF
  type = map(object({
    kubernetes_cluster_version             = string
    kubernetes_cluster_ssh_key             = string
    enable_automatic_channel_upgrade_patch = optional(bool, false)
    system_node_pool = object({
      min_nodes = number
      max_nodes = number
    })

    linux_node_pool = object({
      max_nodes = number
      max_pods  = number
    })

    node_os_maintenance_window_config = object({
      frequency  = string
      start_time = string
      is_prod    = bool
    })

    availability_zones = list(string)
  }))
}

variable "csi_driver_enabled" {
  default = true
}