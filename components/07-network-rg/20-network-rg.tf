resource "azurerm_resource_group" "network_resource_group" {
  location = var.location

  name = format("%s-%s-network-rg",
    var.project,
    var.environment
  )
  tags = module.ctags.common_tags
}

module "ctags" {
  source      = "git::https://github.com/hmcts/terraform-module-common-tags.git?ref=master"
  environment = var.environment
  product     = var.product
  builtFrom   = var.builtFrom
}
