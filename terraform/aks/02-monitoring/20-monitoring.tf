resource "azurerm_resource_group" "this" {
  location = var.location

  name = format("%s-%s-monitoring-rg",
    var.project,
    var.environment
  )
  tags = local.common_tags

}

#--------------------------------------------------------------
# Azure Log Analytics
#--------------------------------------------------------------

resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  name = format("%s-%s-law",
    var.project,
    var.environment
  )

  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = var.kubernetes_cluster_log_analytics_workspace_sku

  tags = local.common_tags
}

resource "azurerm_log_analytics_solution" "log_analytics_solution" {
  solution_name = "ContainerInsights"

  location              = var.location
  resource_group_name   = azurerm_resource_group.this.name
  workspace_resource_id = azurerm_log_analytics_workspace.log_analytics_workspace.id
  workspace_name        = azurerm_log_analytics_workspace.log_analytics_workspace.name

  plan {
    publisher = var.kubernetes_cluster_log_analytics_solution_publisher
    product   = var.kubernetes_cluster_log_analytics_solution_product
  }
}

