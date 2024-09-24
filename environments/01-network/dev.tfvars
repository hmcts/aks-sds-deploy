enable_debug = "true"

network_address_space                  = "10.145.0.0/18"
aks_00_subnet_cidr_blocks              = "10.145.0.0/20"
aks_01_subnet_cidr_blocks              = "10.145.16.0/20"
iaas_subnet_cidr_blocks                = "10.145.32.0/25"
application_gateway_subnet_cidr_blocks = "10.145.32.128/25"
postgresql_subnet_cidr_blocks          = "10.145.40.0/25"
postgresql_subnet_expanded_cidr_blocks = "10.145.42.0/23"

additional_subnets = [
  {
    name           = "vh_private_endpoints"
    address_prefix = "10.145.33.0/25"
  },
  {
    name           = "api-management"
    address_prefix = "10.145.33.128/25"
  },
  {
    name           = "redis",
    address_prefix = "10.145.34.0/25"
  },
  {
    name           = "private-endpoints"
    address_prefix = "10.145.36.0/22"
  },
]

private_dns_subscription = "1baf5470-1c3e-40d3-a6f7-74bfbce4b348"
private_dns_zones = [
  "dev.platform.hmcts.net",
  "platform.hmcts.net",
  "dom1.infra.int",
  "mailrelay.platform.hmcts.net",
  "staging.platform.hmcts.net",
  "aat.platform.hmcts.net",
  "service.core-compute-aat.internal"
]

hub = "nonprod"

additional_routes = [
  {
    name                   = "CGW-Proxy"
    address_prefix         = "10.24.1.253/32"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.11.72.37"
  },
  {
    name                   = "ss-stg-vnet"
    address_prefix         = "10.148.0.0/18"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.11.72.36"
  },
  {
    name                   = "pre-vnet01-stg"
    address_prefix         = "10.101.0.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.11.72.36"
  },
]

additional_routes_application_gateway = [
  {
    name                   = "vh-perf-test-dev"
    address_prefix         = "10.50.10.96/28"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.11.72.36"
  },
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
  },
  {
    name                   = "dynatrace-nonprod-vnet"
    address_prefix         = "10.10.80.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.11.72.36"
  },
  {
    name                   = "jbox-nonprod"
    address_prefix         = "10.25.250.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.11.72.36"
  }
]
