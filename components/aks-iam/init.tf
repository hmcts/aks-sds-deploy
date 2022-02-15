terraform {
  required_version = ">= 1.0.7"

  backend "azurerm" {
    subscription_id = "04d27a32-7a07-48bf3-95b8-3c8691e1a263"
  }
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = "2.77.0"
      configuration_aliases = [azurerm.hmcts-control]
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  is_dev  = var.environment == "dev" || var.environment == "test" || var.environment == "demo"  ? true : false
}

provider "azurerm" {
  alias                      = "dts-ss-stg"
  skip_provider_registration = "true"
  features {}
  subscription_id = "74dacd4f-a248-45bb-a2f0-af700dc4cf68"
}