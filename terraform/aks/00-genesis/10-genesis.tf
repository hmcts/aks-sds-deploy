module "genesis" {
  source      = "git::https://github.com/hmcts/aks-module-genesis.git?ref=master"
  environment = var.environment
  tags        = local.common_tags
}
