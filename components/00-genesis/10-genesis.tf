module "genesis" {
  source           = "git::https://github.com/hmcts/aks-module-genesis.git?ref=master"
  environment      = var.env
  tags             = local.common_tags
  developers_group = local.developers_group
  business_area    = lower(module.ctags.common_tags["businessArea"])
}

module "ctags" {
  source       = "git::https://github.com/hmcts/terraform-module-common-tags.git?ref=master"
  environment  = var.env
  product      = var.product
  builtFrom    = var.builtFrom
  expiresAfter = var.expiresAfter
}

locals {
  common_tags = merge(module.ctags.common_tags, {
    managedBy = var.managedby
  })
}
