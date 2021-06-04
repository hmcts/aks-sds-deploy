terraform {
  required_version = ">= 0.12.0"

  backend "azurerm" {
    subscription_id = "04d27a32-7a07-48b3-95b8-3c8691e1a263"
  }
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = "2.57.0"
      configuration_aliases = [azurerm.hmcts-control]
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  acr = {
    ss = {
      subscription = "5ca62022-6aa2-4cee-aaa7-e7536c8d566c"
    }
    global = {
      subscription = "8999dec3-0104-4a27-94ee-6588559729d1"
    }
  }
}

provider "azurerm" {
  subscription_id            = local.acr[var.project].subscription
  skip_provider_registration = "true"
  features {}
  alias = "acr"
}

provider "azurerm" {
  subscription_id            = local.acr["global"].subscription
  skip_provider_registration = "true"
  features {}
  alias = "global_acr"
}

provider "azurerm" {
  alias                      = "hmcts-control"
  skip_provider_registration = "true"
  features {}
  subscription_id = "04d27a32-7a07-48b3-95b8-3c8691e1a263"
}
