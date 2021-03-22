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
  ]
}

locals {
  hub = {
    nonprod = {
      subscription = "fb084706-583f-4c9a-bdab-949aac66ba5c"
      ukSouth = {
        name        = "hmcts-hub-nonprodi"
        next_hop_ip = "10.11.72.36"
      }
      ukWest = {
        name        = "ukw-hub-nonprodi"
        next_hop_ip = "10.49.72.36"
      }
    }
    sbox = {
      subscription = "ea3a8c1e-af9d-4108-bc86-a7e2d267f49c"
      ukSouth = {
        name        = "hmcts-hub-sbox-int"
        next_hop_ip = "10.10.200.36"
      }
      ukWest = {
        name        = "ukw-hub-sbox-int"
        next_hop_ip = "10.48.200.36"
      }
    }
    prod = {
      subscription = "0978315c-75fe-4ada-9d11-1eb5e0e0b214"
      ukSouth = {
        name        = "hmcts-hub-prod-int"
        next_hop_ip = "10.11.8.36"
      }
      ukWest = {
        name        = "ukw-hub-prod-int"
        next_hop_ip = "10.49.8.36"
      }
    }
  }

  criticality = {
    sbox     = "Low"
    aat      = "High"
    stg      = "High"
    prod     = "High"
    ithc     = "Medium"
    test     = "Medium"
    perftest = "Medium"
    demo     = "Medium"
    dev      = "Low"
  }

  env_display_names = {
    sbox     = "Sandbox"
    aat      = "Staging"
    stg      = "Staging"
    prod     = "Production"
    ithc     = "ITHC"
    test     = "Test"
    perftest = "Test"
    dev      = "Development"
    demo     = "Demo"
  }

  common_tags = {
    "managedBy"          = "SS DevOps"
    "solutionOwner"      = "Shared Services"
    "activityName"       = "AKS"
    "dataClassification" = "Internal"
    "automation"         = "AKS Build Infrastructure"
    "costCentre"         = "ss-aks" // until we get a better one, this is the generic cft contingency one
    "environment"        = local.env_display_names[var.environment]
    "criticality"        = local.criticality[var.environment]
  }
}

variable "additional_routes" {
  default = []
}

variable "additional_subnets" {
  default = []
}
