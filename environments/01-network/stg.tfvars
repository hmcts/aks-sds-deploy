enable_debug = "true"

network_address_space                  = "10.148.0.0/18"
aks_00_subnet_cidr_blocks              = "10.148.0.0/20"
aks_01_subnet_cidr_blocks              = "10.148.16.0/20"
iaas_subnet_cidr_blocks                = "10.148.32.0/25"
application_gateway_subnet_cidr_blocks = "10.148.32.128/25"
postgresql_subnet_cidr_blocks          = "10.148.40.0/25"

additional_subnets = [
  {
    name           = "vh_private_endpoints"
    address_prefix = "10.148.33.0/25"
  },
  {
    name           = "api-management"
    address_prefix = "10.148.33.128/25"
  },
  {
    name           = "redis",
    address_prefix = "10.148.34.0/25"
  },
  {
    name           = "private-endpoints"
    address_prefix = "10.148.36.0/22"
  }
]


private_dns_subscription = "1baf5470-1c3e-40d3-a6f7-74bfbce4b348"
private_dns_zones = [
  "staging.platform.hmcts.net",
  "dev.platform.hmcts.net",
  "aat.platform.hmcts.net"
]

hub = "prod"

application_gateway_routes = [
  {
    name                   = "ss-dev-vnet"
    address_prefix         = "10.145.0.0/18"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.11.8.36"
  },
  {
    name                   = "ss-ptl-vnet"
    address_prefix         = "10.147.64.0/18"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.11.8.36"
  }
]

additional_routes = [
  {
    name                   = "10_0_0_0"
    address_prefix         = "10.0.0.0/8"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.11.8.36"
  },
  {
    name                   = "172_16_0_0"
    address_prefix         = "172.16.0.0/12"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.11.8.36"
  },
  {
    name                   = "192_168_0_0"
    address_prefix         = "192.168.0.0/16"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.11.8.36"
  },
  {
    name                   = "mi_data_sftp_0"
    address_prefix         = "10.24.254.129/32"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.11.8.36"
  },
  {
    name                   = "mi_data_sftp_1"
    address_prefix         = "10.24.254.130/32"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.11.8.36"
  }
]
