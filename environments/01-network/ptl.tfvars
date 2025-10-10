enable_debug = "true"

network_address_space                  = "10.147.64.0/18"
aks_00_subnet_cidr_blocks              = "10.147.64.0/20"
aks_01_subnet_cidr_blocks              = "10.147.80.0/20"
iaas_subnet_cidr_blocks                = "10.147.96.0/25"
application_gateway_subnet_cidr_blocks = "10.147.96.128/25"
postgresql_subnet_cidr_blocks          = "10.147.97.128/25"
postgresql_subnet_expanded_cidr_blocks = "10.147.98.0/25"

additional_subnets = [
  {
    name           = "redis",
    address_prefix = "10.147.97.0/25"
  },
  {
    name           = "private-endpoints"
    address_prefix = "10.147.100.0/22"
  }
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
    name                   = "demo_aks_vnet"
    address_prefix         = "10.51.64.0/18"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.11.72.36"
  },
  {
    name                   = "ithc_aks_vnet"
    address_prefix         = "10.143.0.0/18"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.11.72.36"
  },
  {
    name                   = "test_aks_vnet"
    address_prefix         = "10.141.0.0/18"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.11.72.36"
  },
  {
    name                   = "test_postgresql_subnet"
    address_prefix         = "10.141.40.0/25"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.11.72.36"
  },
  {
    name                   = "jumpbox_nonprod_vnet"
    address_prefix         = "10.25.250.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.11.72.36"
  },
  {
    name                   = "pre_vnet_dev"
    address_prefix         = "10.40.12.0/26"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.11.72.36"
  },
  {
    name                   = "pre_vnet_demo"
    address_prefix         = "10.50.12.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.11.72.36"
  },
  {
    name                   = "pre_vnet_test"
    address_prefix         = "10.70.21.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.11.72.36"
  },
  {
    name                   = "dc_vnet_dev"
    address_prefix         = "10.11.74.32/27"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.11.72.36"
  },
  {
    name                   = "dc_vnet_test"
    address_prefix         = "10.11.75.32/27"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.11.72.36"
  },
  {
    name                   = "mi_vnet_dev"
    address_prefix         = "10.168.1.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.11.72.36"
  },
  {
    name                   = "mi_vnet_ithc"
    address_prefix         = "10.168.4.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.11.72.36"
  },
  {
    name                   = "bais_vnet_stg"
    address_prefix         = "10.225.251.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.11.72.36"
  },
  {
    name                   = "darts_modernisation_vnet_dev"
    address_prefix         = "10.101.200.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.11.72.36"
  },
  {
    name                   = "heritage_nle_int_vnet_addrspace_01"
    address_prefix         = "10.25.240.0/21"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.11.72.36"
  },
  {
    name                   = "heritage_nle_int_vnet_addrspace_02"
    address_prefix         = "10.225.240.0/21"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.11.72.36"
  }
]

ingest_peering_config = {
  sbox = {
    vnet_name      = "ingest00-vnet-sbox"
    resource_group = "ingest00-network-rg"
    provider_alias = "dlrm-ingest-sbox"
  }
}
