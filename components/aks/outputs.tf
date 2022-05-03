output "clusters" {
  value = join(" ", flatten([for cluster in module.kubernetes : cluster[*].cluster]))
  sensitive = false
}
