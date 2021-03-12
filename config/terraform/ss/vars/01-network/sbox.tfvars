enable_debug = "true"

network_address_space                  = "10.140.0.0/18"
aks_00_subnet_cidr_blocks              = "10.140.0.0/20"
aks_01_subnet_cidr_blocks              = "10.140.16.0/20"
iaas_subnet_cidr_blocks                = "10.140.32.0/25"
application_gateway_subnet_cidr_blocks = "10.140.32.128/25"

private_dns_subscription = "1497c3d7-ab6d-4bb7-8a10-b51d03189ee3"
private_dns_zones = [
  "sandbox.platform.hmcts.net",
  "sbox.platform.hmcts.net",
]

hub = "sbox"

additional_routes = [
  {
    name                   = "10_0_0_0"
    address_prefix         = "10.0.0.0/8"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.10.200.36"
  },
  {
    name                   = "172_16_0_0"
    address_prefix         = "172.16.0.0/12"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.10.200.36"
  },
  {
    name                   = "192_168_0_0"
    address_prefix         = "192.168.0.0/16"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.10.200.36"
  },
  {
    name                   = "mi_data_sftp_1"
    address_prefix         = "1.1.1.1/32"
    next_hop_type          = "Internet"
    next_hop_in_ip_address = ""
  }
]