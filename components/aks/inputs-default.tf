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

variable "arm_node_pool" {
  description = "Map to override the linux node pool config"
  default     = {}
}

variable "windows_node_pool" {
  description = "Map to override the windows node pool config"
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

# variable "node_os_maintenance_window_duration" {
#   description = "Duration of maintenance window in hours"
#   default     = 4
# }

# variable "node_os_maintenance_window_frequency" {
#   description = "Frequency of maintenance window, repeat every day, week or month"
#   default     = "Daily"
# }

# variable "node_os_maintenance_window_interval" {
#   description = "The interval for maintenance runs"
#   default     = 1
# }

# variable "node_os_maintenance_window_day_of_week" {
#   description = "The day of the week for the maintenance run. Required in combination with weekly frequency."
#   default     = null
# }

# variable "node_os_maintenance_window_start_time" {
#   description = "Start time of maintenance run format HH:mm"
#   default     = null
# }

# variable "node_os_maintenance_window_utc_offset" {
#   description = "Used to adjust time zome of start time, +/-HH:mm"
#   default     = null
# }

# variable "node_os_maintenance_window_start_date" {
#   description = "Date when maintenance window will start"
#   default     = null
# }

variable "node_os_maintenance_window_config" {
  type = object({
    frequency   = string
    interval    = number
    duration    = number
    day_of_week = optional(string)
    start_time  = optional(string)
    utc_offset  = optional(string)
    start_date  = optional(string)
  })
  default = {
    frequency   = "Weekly"
    interval    = 1
    duration    = 4
    day_of_week = "Monday"
    utc_offset  = null
    start_date  = null
  }
}