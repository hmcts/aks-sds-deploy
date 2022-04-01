output "clusters" {
  # value     = join(" ", toset(module.kubernetes[*]).cluster)
  # value = join(" ", [for cluster in module.kubernetes : cluster[*].cluster[*]])
  value = join(" ", flatten([for cluster in module.kubernetes : cluster[*].cluster]))
  # value     = module.kubernetes[*]
  sensitive = false
}
