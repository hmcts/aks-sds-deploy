locals {
  developers_group = "DTS SDS Developers"
}

variable "public_ip_names" {
  description = "List of names of IP addresss to create"
  default     = []
}