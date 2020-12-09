enable_debug = "true"

network_address_space                  = "10.140.0.0/18"
aks_00_subnet_cidr_blocks              = "10.140.0.0/20"
aks_01_subnet_cidr_blocks              = "10.140.16.0/20"
iaas_subnet_cidr_blocks                = "10.140.32.0/25"
application_gateway_subnet_cidr_blocks = "10.140.32.128/25"

private_dns_subscription = "1497c3d7-ab6d-4bb7-8a10-b51d03189ee3"
private_dns_zones = [
  "sandbox.platform.hmcts.net",
]

hub = "sbox"
