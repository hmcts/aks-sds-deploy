terraform {
  required_version = ">= 1.2.2"

  backend "azurerm" {
    subscription_id = "04d27a32-7a07-48b3-95b8-3c8691e1a263"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.60.0"
    }
  }
}

variable "subscription_id" {}

provider "azurerm" {
  features {}
  skip_provider_registration = "true"
  subscription_id            = var.subscription_id
}

provider "azurerm" {
  alias                      = "hmcts-control"
  skip_provider_registration = "true"
  features {}
  subscription_id = "04d27a32-7a07-48b3-95b8-3c8691e1a263"
}

provider "azurerm" {
  subscription_id = "5ca62022-6aa2-4cee-aaa7-e7536c8d566c"

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
  subscription_id            = "a8140a9e-f1b0-481f-a4de-09e2ee23f7ab"
  skip_provider_registration = "true"
  features {}
  alias = "sds_sbox_acr"
}
