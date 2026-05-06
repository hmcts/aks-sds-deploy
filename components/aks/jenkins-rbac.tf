locals {
  jenkins_environment_mis = {
    demo = {
      subscription_id     = "c68a4bed-4c3d-4956-af51-4ae164c1957c"
      name                = "jenkins-demo-mi"
      resource_group_name = "managed-identities-demo-rg"
    }
    dev = {
      subscription_id     = "867a878b-cb68-4de5-9741-361ac9e178b6"
      name                = "jenkins-dev-mi"
      resource_group_name = "managed-identities-dev-rg"
    }
    ithc = {
      subscription_id     = "ba71a911-e0d6-4776-a1a6-079af1df7139"
      name                = "jenkins-ithc-mi"
      resource_group_name = "managed-identities-ithc-rg"
    }
    prod = {
      subscription_id     = "5ca62022-6aa2-4cee-aaa7-e7536c8d566c"
      name                = "jenkins-prod-mi"
      resource_group_name = "managed-identities-prod-rg"
    }
    ptl = {
      subscription_id     = "6c4d2513-a873-41b4-afdd-b05a33206631"
      name                = "jenkins-ptl-mi"
      resource_group_name = "managed-identities-ptl-rg"
    }
    ptlsbox = {
      subscription_id     = "64b1c6d6-1481-44ad-b620-d8fe26a2c768"
      name                = "jenkins-ptlsbox-mi"
      resource_group_name = "managed-identities-ptlsbox-rg"
    }
    sbox = {
      subscription_id     = "a8140a9e-f1b0-481f-a4de-09e2ee23f7ab"
      name                = "jenkins-sbox-mi"
      resource_group_name = "managed-identities-sbox-rg"
    }
    stg = {
      subscription_id     = "74dacd4f-a248-45bb-a2f0-af700dc4cf68"
      name                = "jenkins-stg-mi"
      resource_group_name = "managed-identities-stg-rg"
    }
    test = {
      subscription_id     = "3eec5bde-7feb-4566-bfb6-805df6e10b90"
      name                = "jenkins-test-mi"
      resource_group_name = "managed-identities-test-rg"
    }
  }
}

provider "azurerm" {
  subscription_id            = local.jenkins_environment_mis[var.env].subscription_id
  skip_provider_registration = "true"
  features {}
  alias = "jenkins_mi"
}

data "azurerm_user_assigned_identity" "jenkins_environment_mi" {
  provider            = azurerm.jenkins_mi
  name                = local.jenkins_environment_mis[var.env].name
  resource_group_name = local.jenkins_environment_mis[var.env].resource_group_name
}

resource "azurerm_role_assignment" "jenkins_environment_mi_aks_admin" {
  for_each             = module.kubernetes
  principal_id         = data.azurerm_user_assigned_identity.jenkins_environment_mi.principal_id
  role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
  scope                = "${azurerm_resource_group.kubernetes_resource_group[each.key].id}/providers/Microsoft.ContainerService/managedClusters/${var.project}-${var.env}-${each.key}-${var.service_shortname}"
}
