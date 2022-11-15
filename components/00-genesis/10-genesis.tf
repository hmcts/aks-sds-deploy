module "genesis" {
  source           = "git::https://github.com/hmcts/aks-module-genesis.git?ref=master"
  environment      = var.env
  tags             = module.ctags.common_tags
  developers_group = local.developers_group
}

module "ctags" {
  source      = "git::https://github.com/hmcts/terraform-module-common-tags.git?ref=master"
  environment = var.env
  product     = var.product
  builtFrom   = var.builtFrom
}
