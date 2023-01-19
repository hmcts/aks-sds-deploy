terraform {
  required_version = ">= 1.2.2"

  backend "azurerm" {
    subscription_id = "04d27a32-7a07-48b3-95b8-3c8691e1a263"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.39.1"
    }
  }
}

variable "subscription_id" {}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}
