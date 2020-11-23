enable_debug = "true"

network_address_space                  = "10.141.0.0/18"
aks_00_subnet_cidr_blocks              = "10.141.0.0/20"
aks_01_subnet_cidr_blocks              = "10.141.16.0/20"
iaas_subnet_cidr_blocks                = "10.141.32.0/25"
application_gateway_subnet_cidr_blocks = "10.141.32.128/25"

private_dns_subscription = "1baf5470-1c3e-40d3-a6f7-74bfbce4b348"
private_dns_zones = [
  "test.platform.hmcts.net",
  "privatelink.database.windows.net",
  "privatelink.blob.core.windows.net",
  "privatelink.vaultcore.azure.net",
  "privatelink.datafactory.azure.net",
  "privatelink.postgres.database.azure.com"
]

hub = "nonprod"
