variable "location" {
  default = "uksouth"
}

variable "service_shortname" {
  default = "aks"
}

variable "private_endpoint_private_dns_zones" {
  default = [
    "privatelink.database.windows.net",
    "privatelink.blob.core.windows.net",
    "privatelink.vaultcore.azure.net",
    "privatelink.datafactory.azure.net",
    "privatelink.postgres.database.azure.com",
    "privatelink.dev.azuresynapse.net",
    "privatelink.sql.azuresynapse.net",
    "privatelink.redis.cache.windows.net",
    "privatelink.service.signalr.net",
    "privatelink.servicebus.windows.net",
    "private.postgres.database.azure.com",
    "privatelink.azurewebsites.net"
  ]
}

locals {
  hub = {
    nonprod = {
      subscription = "fb084706-583f-4c9a-bdab-949aac66ba5c"
      ukSouth = {
        name         = "hmcts-hub-nonprodi"
        peering_name = "hubUkS"
        next_hop_ip  = "10.11.72.36"
      }
    }
    sbox = {
      subscription = "ea3a8c1e-af9d-4108-bc86-a7e2d267f49c"
      ukSouth = {
        name         = "hmcts-hub-sbox-int"
        peering_name = "hubUkS"
        next_hop_ip  = "10.10.200.36"
      }
    }
    prod = {
      subscription = "0978315c-75fe-4ada-9d11-1eb5e0e0b214"
      ukSouth = {
        name         = "hmcts-hub-prod-int"
        peering_name = "hubUkS"
        next_hop_ip  = "10.11.8.36"
      }
    }
  }

  hub_to_env_mapping = {
    sbox    = ["sbox", "ptlsbox"]
    nonprod = ["demo", "dev", "aat", "test", "ithc", "ptl", "stg"]
    prod    = ["prod", "stg", "ptl"]
  }

  regions = [
    "ukSouth"
  ]

}

variable "additional_routes" {
  default = []
}

variable "additional_subnets" {
  default = []
}

variable "expiresAfter" {
  default = "3000-01-01"
}
