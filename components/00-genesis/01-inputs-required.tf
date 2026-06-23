variable "env" {}

variable "builtFrom" {}

variable "product" {}

variable "managedby" {
  description = "Team responsible for managing these resources"
  type        = string
  default     = "DTS Platform Operations"
}

variable "project" {}
