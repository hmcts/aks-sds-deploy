terraform {
  required_version = ">= 0.12.0"

  backend "azurerm" {
    subscription_id = "04d27a32-7a07-48b3-95b8-3c8691e1a263"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.57.0"
    }
  }
}

variable "subscription_id" {}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "azurerm" {
  alias                      = "hmcts-control"
  skip_provider_registration = "true"
  features {}
  subscription_id = "04d27a32-7a07-48b3-95b8-3c8691e1a263"
}

// TODO delete after applying MI in all ENVs
// working around 'Error: Provider configuration not present'
provider "azurerm" {
  subscription_id            = local.acr[var.project].subscription
  skip_provider_registration = "true"
  features {}
  alias = "acr"
}

provider "azurerm" {
  subscription_id            = local.log_analytics_subscription_id
  skip_provider_registration = "true"
  features {}
  alias = "log_analytics"
}

provider "azurerm" {
  subscription_id            = local.acr["sds_sbox"].subscription
  skip_provider_registration = "true"
  features {}
  alias = "sds_sbox_acr"
}