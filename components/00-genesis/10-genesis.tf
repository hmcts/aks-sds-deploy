locals {
    mi_sds = {
    # DTS-SHAREDSERVICES-SBOX
    sbox = {
      subscription_id = "a8140a9e-f1b0-481f-a4de-09e2ee23f7ab"
    }
    # DTS-SHAREDSERVICES-STG
    dev = {
      subscription_id = "74dacd4f-a248-45bb-a2f0-af700dc4cf68"
    }
    stg = {
      subscription_id = "74dacd4f-a248-45bb-a2f0-af700dc4cf689"
    }
    # DTS-SHAREDSERVICES-ITHC
    ithc = {
      subscription_id = "ba71a911-e0d6-4776-a1a6-079af1df7139"
    }
    # DTS-SHAREDSERVICES-TEST
    test = {
      subscription_id = "3eec5bde-7feb-4566-bfb6-805df6e10b90"
    }
    # DTS-SHAREDSERVICES-DEMO
    demo = {
      subscription_id = "c68a4bed-4c3d-4956-af51-4ae164c1957c"
    }
    # DTS-SHAREDSERVICES-PROD
    prod = {
      subscription_id = "5ca62022-6aa2-4cee-aaa7-e7536c8d566c"
    }
    # DTS-SHAREDSERVICESPTL-SBOX
    ptlsbox = {
      subscription_id = "64b1c6d6-1481-44ad-b620-d8fe26a2c768"
    }
    # DTS-SHAREDSERVICESPTL
    ptl = {
      subscription_id = "6c4d2513-a873-41b4-afdd-b05a33206631"
    }
  }
}

module "genesis" {
  source                  = "git::https://github.com/hmcts/aks-module-genesis.git?ref=dtspo-30482-grant-per-env-jenkins-mi-on-kv"
  environment             = var.env
  tags                    = module.ctags.common_tags
  developers_group        = local.developers_group
  business_area           = lower(module.ctags.common_tags["businessArea"])
  jenkins_provider_sub_id = local.mi_cft[var.env].subscription_id
  jenkins_mi_name         = "jenkins-${var.env}-mi"
  jenkins_mi_rg_name      = "managed-identities-${var.env}-rg"
}

module "ctags" {
  source       = "git::https://github.com/hmcts/terraform-module-common-tags.git?ref=master"
  environment  = var.env
  product      = var.product
  builtFrom    = var.builtFrom
  expiresAfter = var.expiresAfter
}
