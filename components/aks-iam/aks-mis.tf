data "azurerm_resource_group" "mi_stg_rg" {
  provider = azurerm.dts-ss-stg
  name     = "managed-identities-stg-rg"

  count    = local.is_dev ? 1 : 0
}

resource "azurerm_role_assignment" "dev_to_stg" {
  count                = local.is_dev ? var.cluster_count : 0
  provider             = azurerm.dts-ss-stg
  role_definition_name = "Managed Identity Operator"
  principal_id         = data.azurerm_kubernetes_cluster.kubernetes["${count.index}"].kubelet_identity[0].object_id
  scope                = data.azurerm_resource_group.mi_stg_rg.id
}

data "azurerm_kubernetes_cluster" "kubernetes" {
  count               = var.cluster_count
  name                = "${var.project}-${var.environment}-0${count.index}-${var.service_shortname}"
  resource_group_name = "${var.project}-${var.environment}-0${count.index}-rg"
}