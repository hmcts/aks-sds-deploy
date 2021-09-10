variable "location" {
  default = "uksouth"
}

variable "service_shortname" {
  default = "aks"
}

variable "ptl_cluster" {
  default = false
}

variable "system_node_pool" {
  description = "Map to override the system node pool config"
}

variable "linux_node_pool" {
  description = "Map to override the linux node pool config"

}

variable "windows_node_pool" {
  description = "Map to override the windows node pool config"

}

variable "sku_tier" {
  default = "Free"
}
