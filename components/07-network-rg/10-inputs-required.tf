# General
variable "env" {}

variable "project" {}

variable "builtFrom" {}

variable "product" {}

variable "managedBy" {
  description = "Team responsible for managing these resources"
  type        = string
  default     = "DTS Platform Operations"
}

variable "enable_debug" {}

variable "control_vault" {}
