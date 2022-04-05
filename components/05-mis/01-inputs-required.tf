variable "environment" {}

variable "project" {}

variable "control_vault" {}

variable "builtFrom" {}

variable "product" {}

variable "clusters" {
  type        = list(string)
  description = "List of clusters to manage e.g [\"00\", \"01\"] "
  default     = []
}