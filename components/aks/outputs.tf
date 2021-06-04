output "clusters" {
  value = join(" ", module.kubernetes[*].cluster)
  sensitive = false
}
