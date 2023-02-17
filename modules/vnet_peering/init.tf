
terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = "3.44.1"
      configuration_aliases = [azurerm.initiator, azurerm.target]
    }
  }
}
