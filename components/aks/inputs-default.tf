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
  default = "Standard"
}

variable "system_node_pool" {
  description = "Map to override the system node pool config"
  default     = {}
}

variable "enable_automatic_channel_upgrade_patch" {
  default = false
}

variable "autoShutdown" {
  default = false
}

variable "expiresAfter" {
  default = "3000-01-01"
}

variable "startupMode" {
  default = null
}

variable "monitor_diagnostic_setting" {
  default = false
}

variable "kube_audit_admin_logs_enabled" {
  default = false
}

variable "monitor_diagnostic_setting_metrics" {
  default = false
}

variable "cluster_automatic" {
  default = false
}

variable "node_os_maintenance_window_config" {
  type = object({
    frequency   = optional(string, "Weekly")
    interval    = optional(number, 1)
    duration    = optional(number, 4)
    day_of_week = optional(string, "Monday")
    start_time  = optional(string, "23:00")
    utc_offset  = optional(string, "+00:00")
    start_date  = optional(string, null)
    is_prod     = optional(bool, true)
  })
  default = {}
}
