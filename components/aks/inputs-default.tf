variable "location" {
  default = "uksouth"
}

variable "service_shortname" {
  default = "aks"
}

variable "oms_agent_enabled" {
  default = false
}

variable "ptl_cluster" {
  default = false
}

variable "sku_tier" {
  default = "Free"
}

variable "system_node_pool" {
  description = "Map to override the system node pool config"
  default     = {}
}

variable "linux_node_pool" {
  description = "Map to override the linux node pool config"
  default     = {}
}

variable "windows_node_pool" {
  description = "Map to override the windows node pool config"
  default     = {}
}
