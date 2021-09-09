variable "location" {
  default = "uksouth"
}

variable "service_shortname" {
  default = "aks"
}

variable "ptl_cluster" {
  default = false
} 

variable "kubernetes_cluster_agent_min_count" {
  default = 1
}
variable "kubernetes_cluster_agent_max_count" {
  default = 3
}
variable "kubernetes_cluster_agent_vm_size" {
  default = "Standard_DS3_v2"
}

variable "node_pools" {
  default = {

    system = {
      min_nodes = 1,
      max_nodes = 3,
      vm_size = "Standard_DS3_v2"
    },

    linux = {
      min_nodes = 2,
      max_nodes = 5,
      vm_size = "Standard_DS3_v2"
    },

    msnode = {
      min_nodes = 2,
      max_nodes = 5,
      vm_size = "Standard_DS3_v2"
    }
  }
}