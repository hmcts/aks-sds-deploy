variable "application_name" {
  default = "flux"
}

locals {
  // TODO delete after applying MI in all ENVs
  // working around 'Error: Provider configuration not present'
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

  log_analytics_env_mapping = {
    sandbox = ["sbox"]
    nonprod = ["dev", "test", "ithc", "demo", "stg"]
    prod    = ["prod", "mgmt"]
  }

  log_analytics_workspace = {
    sandbox = {
      subscription_id = "bf308a5c-0624-4334-8ff8-8dca9fd43783"
      name            = "hmcts-sandbox"
    }
    nonprod = {
      subscription_id = "1c4f0704-a29e-403d-b719-b90c34ef14c9"
      name            = "hmcts-nonprod"
    }
    prod = {
      subscription_id = "8999dec3-0104-4a27-94ee-6588559729d1"
      name            = "hmcts-prod"
    }
  }
  log_analytics_subscription_id = local.log_analytics_workspace[[for x in keys(local.log_analytics_env_mapping) : x if contains(local.log_analytics_env_mapping[x], var.environment)][0]].subscription_id
  resolved_name = local.log_analytics_workspace[[for x in keys(local.log_analytics_env_mapping) : x if contains(local.log_analytics_env_mapping[x], var.environment)][0]].name

}

variable "location" {
  default = "UK South"
}
