module "genesis" {
  source           = "git::https://github.com/hmcts/aks-module-genesis.git?ref=DTSPO-1032-ptlsbox"
  environment      = var.environment
  tags             = local.common_tags
  developers_group = local.developers_group
}