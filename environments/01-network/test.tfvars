enable_debug = "true"

network_address_space                  = "10.141.0.0/18"
aks_00_subnet_cidr_blocks              = "10.141.0.0/20"
aks_01_subnet_cidr_blocks              = "10.141.16.0/20"
iaas_subnet_cidr_blocks                = "10.141.32.0/25"
application_gateway_subnet_cidr_blocks = "10.141.32.128/25"
postgresql_subnet_cidr_blocks          = "10.141.40.0/25"

additional_subnets = [
  {
    name           = "vh_private_endpoints"
    address_prefix = "10.141.33.0/25"
  },
  {
    name           = "api-management"
    address_prefix = "10.141.33.128/25"
  },
  {
    name           = "redis",
    address_prefix = "10.141.34.0/25"
  },
  {
    name           = "private-endpoints"
    address_prefix = "10.141.36.0/22"
  }
]

private_dns_subscription = "1baf5470-1c3e-40d3-a6f7-74bfbce4b348"
private_dns_zones = [
  "test.platform.hmcts.net",
  "perftest.platform.hmcts.net",
  "platform.hmcts.net",
  "mailrelay.platform.hmcts.net",
]

hub = "nonprod"

additional_routes_application_gateway = [
  {
    name                   = "vh-infra-core-ado"
    address_prefix         = "10.10.52.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.11.72.36"
  },
  {
    name                   = "hmi-ss-dev-vnet"
    address_prefix         = "10.101.1.64/26"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.11.72.36"
  },
  {
    name                   = "hmi-ss-test-vnet"
    address_prefix         = "10.101.1.128/26"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.11.72.36"
  },
  {
    name                   = "hmi-ss-stg-vnet"
    address_prefix         = "10.101.1.192/26"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.11.72.36"
  },
  {
    name                   = "hmi-ss-ithc-vnet"
    address_prefix         = "10.101.2.64/26"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.11.72.36"
  },
  {
    name                   = "hmi-ss-demo-vnet"
    address_prefix         = "10.101.2.128/26"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.11.72.36"
  }
]
