variable "application_name" {
  default = "flux"
}

locals {
  acr = {
    ss = {
      subscription = "5ca62022-6aa2-4cee-aaa7-e7536c8d566c"
      project      = "sds"
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
