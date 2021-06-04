output "clusters" {
  value = join(" ", module.kubernetes[*].cluster)
  sensitive = false
}

output "test" {
  value = "test"
  sensitive = false
}