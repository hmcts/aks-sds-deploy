

variable "location" {
  default = "uksouth"
}

variable "service_shortname" {
  default = "aks"
}

# locals {
#   criticality = {
#     sbox     = "Low"
#     ptlsbox  = "Low"
#     aat      = "High"
#     stg      = "High"
#     prod     = "High"
#     ptl      = "High"
#     ithc     = "Medium"
#     test     = "Medium"
#     perftest = "Medium"
#     demo     = "Medium"
#     dev      = "Low"
#   }

#   env_display_names = {
#     sbox     = "Sandbox"
#     ptlsbox  = "Sandbox"
#     aat      = "Staging"
#     stg      = "Staging"
#     ptl      = "Production"
#     prod     = "Production"
#     ithc     = "ITHC"
#     test     = "Test"
#     perftest = "Test"
#     dev      = "Development"
#     demo     = "Demo"
#   }

# }
