enable_debug = "true"

network_address_space                  = "10.145.0.0/18"
aks_00_subnet_cidr_blocks              = "10.145.0.0/20"
aks_01_subnet_cidr_blocks              = "10.145.16.0/20"
iaas_subnet_cidr_blocks                = "10.145.32.0/25"
application_gateway_subnet_cidr_blocks = "10.145.32.128/25"

additional_subnets = [
  {
    name           = "vh_private_endpoints"
    address_prefix = "10.145.33.0/25"
  },
  {
    name           = "redis",
    address_prefix = "10.145.34.0/25"
  },
]

private_dns_subscription = "1baf5470-1c3e-40d3-a6f7-74bfbce4b348"
private_dns_zones = [
  "dev.platform.hmcts.net",
  "platform.hmcts.net",
  "dom1.infra.int",
  "mailrelay.platform.hmcts.net",
  "staging.platform.hmcts.net",
]

hub = "nonprod"

additional_routes = [
  {
    name                   = "stg_aks_vnet"
    address_prefix         = "10.148.0.0/18"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.11.8.36"
  },
]