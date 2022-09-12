module "network" {
  source = "git::https://github.com/hmcts/aks-module-network.git?ref=master"

  resource_group_name = local.network_resource_group_name

  route_next_hop_in_ip_address = local.hub[var.hub].ukSouth.next_hop_ip
  additional_routes            = var.additional_routes
  environment                  = var.env

  network_address_space = var.network_address_space
  network_location      = var.location
  network_shortname     = local.network_shortname
  project               = var.project
  service_shortname     = var.service_shortname

  aks_00_subnet_cidr_blocks              = var.aks_00_subnet_cidr_blocks #UK South
  aks_01_subnet_cidr_blocks              = var.aks_01_subnet_cidr_blocks #UK West # Currently both clusters in UK South
  application_gateway_subnet_cidr_blocks = var.application_gateway_subnet_cidr_blocks
  application_gateway_routes             = var.application_gateway_routes
  iaas_subnet_cidr_blocks                = var.iaas_subnet_cidr_blocks
  additional_subnets                     = var.additional_subnets
  postgresql_subnet_cidr_blocks          = var.postgresql_subnet_cidr_blocks

  tags = module.ctags.common_tags
}

module "ctags" {
  source      = "git::https://github.com/hmcts/terraform-module-common-tags.git?ref=master"
  environment = var.env
  product     = var.product
  builtFrom   = var.builtFrom
}
