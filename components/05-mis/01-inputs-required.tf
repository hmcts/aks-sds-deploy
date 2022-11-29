variable "env" {}

variable "project" {}

variable "control_vault" {}

variable "builtFrom" {}

variable "product" {}

variable "clusters" {
  type        = map(map(string))
  description = <<-EOF
Map of clusters to manage. Example:
clusters = {
  "00" = {
    kubernetes_version = "1.22.6"
  },
  "01" = {
    kubernetes_version = "1.22.6"
  }
}
EOF
}
