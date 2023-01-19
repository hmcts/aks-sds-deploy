variable "application_name" {
  default = "flux"
}

variable "location" {
  default = "UK South"
}
locals {

  is_sbox = var.env == "sbox" ? true : false

  common_tags = module.ctags.common_tags

  log_analytics_env_mapping = {
    sandbox = ["sbox", "ptlsbox"]
    nonprod = ["dev", "test", "ithc", "demo", "stg"]
    prod    = ["prod", "mgmt", "ptl"]
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
  log_analytics_subscription_id = local.log_analytics_workspace[[for x in keys(local.log_analytics_env_mapping) : x if contains(local.log_analytics_env_mapping[x], var.env)][0]].subscription_id
  resolved_name                 = local.log_analytics_workspace[[for x in keys(local.log_analytics_env_mapping) : x if contains(local.log_analytics_env_mapping[x], var.env)][0]].name
}

module "ctags" {
  source       = "git::https://github.com/hmcts/terraform-module-common-tags.git?ref=master"
  environment  = var.env
  product      = var.product
  builtFrom    = var.builtFrom
  expiresAfter = var.expiresAfter
}

variable "expiresAfter" {
  default = "3000-01-01"
}