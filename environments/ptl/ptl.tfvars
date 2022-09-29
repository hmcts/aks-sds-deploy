enable_debug = "true"

network_address_space                  = "10.147.64.0/18"
aks_00_subnet_cidr_blocks              = "10.147.64.0/20"
aks_01_subnet_cidr_blocks              = "10.147.80.0/20"
iaas_subnet_cidr_blocks                = "10.147.96.0/25"
application_gateway_subnet_cidr_blocks = "10.147.96.128/25"
postgresql_subnet_cidr_blocks          = "10.147.97.128/25"

additional_subnets = [
  {
    name           = "redis",
    address_prefix = "10.147.97.0/25"
  },
]

private_dns_subscription = "1baf5470-1c3e-40d3-a6f7-74bfbce4b348"
private_dns_zones = [
  "dev.platform.hmcts.net",
  "demo.platform.hmcts.net",
  "test.platform.hmcts.net",
  "ithc.platform.hmcts.net",
  "staging.platform.hmcts.net",
  "platform.hmcts.net",
  "aat.platform.hmcts.net"
]

hub = "prod"

additional_routes = [
  {
    name                   = "dev_aks_vnet"
    address_prefix         = "10.145.0.0/18"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.11.72.36"
  },
  {
    name                   = "demo_aks_iaas_subnet"
    address_prefix         = "10.51.96.0/25"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.11.72.36"
  },
  {
    name                   = "ithc_aks_iaas_subnet"
    address_prefix         = "10.143.32.0/25"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.11.72.36"
  },
  {
    name                   = "test_aks_iaas_subnet"
    address_prefix         = "10.141.32.0/25"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.11.72.36"
  }
]

clusters = {
  "00" = {
    kubernetes_version = "1.22.6"
  }
}
kubernetes_cluster_agent_min_count = "1"
kubernetes_cluster_agent_max_count = "4"
kubernetes_cluster_ssh_key         = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDGk0M1s1gOt2Sy4Yhl7kvzI5Op0yNbjjghn3fVCTJ8tjF/7j98TuQtxxxr6dWb1ovKbdAmy5d9FFUUXxBGGji8ka0OKHF8Rz5/3IqzMucpTzAfNCe9xP6Y1/qnml8atYToLw3qQDWK0O/+VuK1tk8wj0uvc1xUMGoePCLIqi+7d/kBJzd3ojsi2o+JMLLAUAWbMSRCnGalojCiwSNU5zBJdBtQq2w00L77wbFukjFz5dGnk5UMCiEDNKqz4aDaiNYVq87PE1L55HlR5W1OzmTVldvIkNDuLY8Sp8sJ42nZl6BsZfBux/fM93GByokLIwZfhgFlIuVpz0VF/FVritxuUNkVg5o9z6i06vmzq0s4+HcfyTqkHuMM9uD/A9VVnbwYkQv9PV7flPW4SMOXW2EncIGGd/u1Y3CwJ8P3jNWbjy7A+yVR8N6QqWvZ2tPI5lWwUSq4J4gjbRn78MmrbDMZOWpL0hyXGX3QTJtbIteJz+bgb6H6WPL0rxv7ZbeLxmM="
ptl_cluster                        = true
sku_tier                           = "Paid"
availability_zones                 = ["1"]
