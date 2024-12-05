terraform {
  required_version = ">= 1.2.8"

  backend "azurerm" {
    subscription_id = "04d27a32-7a07-48b3-95b8-3c8691e1a263"
  }
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = "4.9.0"
      configuration_aliases = [azurerm.hmcts-control]
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 1.15.0"
    }
  }
}

provider "azurerm" {
  skip_provider_registration = "true"
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
    sds_sbox = {
      subscription = "a8140a9e-f1b0-481f-a4de-09e2ee23f7ab"
    }
  }
  is_sbox = var.env == "sbox" ? true : false
  is_dev  = var.env == "dev" ? true : false
  is_prod = var.env == "prod" ? true : false
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
  subscription_id            = local.acr["sds_sbox"].subscription
  skip_provider_registration = "true"
  features {}
  alias = "sds_sbox_acr"
}

provider "azurerm" {
  alias                      = "hmcts-control"
  skip_provider_registration = "true"
  features {}
  subscription_id = "04d27a32-7a07-48b3-95b8-3c8691e1a263"
}

#Prod provider is currently having issue with access but provider needs initialised for upgrade so logic is being added to try circumvent it
provider "azurerm" {
  subscription_id            = local.is_prod ? local.acr["ss"].subscription : "74dacd4f-a248-45bb-a2f0-af700dc4cf68"
  skip_provider_registration = "true"
  features {}
  alias = "dts-ss-stg"
}
