enable_debug = "true"

network_address_space                  = "10.147.64.0/18"
aks_00_subnet_cidr_blocks              = "10.147.64.0/20"
aks_01_subnet_cidr_blocks              = "10.147.80.0/20"
iaas_subnet_cidr_blocks                = "10.147.96.0/25"
application_gateway_subnet_cidr_blocks = "10.147.96.128/25"

private_dns_subscription = "1baf5470-1c3e-40d3-a6f7-74bfbce4b348"
private_dns_zones = [
  "platform.hmcts.net"
]

hub = "prod"
