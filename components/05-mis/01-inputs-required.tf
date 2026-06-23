variable "env" {}

variable "project" {}

variable "control_vault" {}

variable "builtFrom" {}

variable "product" {}

variable "managedBy" {
  description = "Team responsible for managing these resources"
  type        = string
  default     = "DTS Platform Operations"
}
