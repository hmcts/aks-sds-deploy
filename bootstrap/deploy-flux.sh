#!/usr/bin/env bash
set -e

source "$(dirname "$0")/deploy-flux-util-functions.sh"

ENVIRONMENT="${3}"
CLUSTER_NAME="${6}"
AGENT_BUILDDIRECTORY=/tmp
KUSTOMIZE_VERSION=5.6.0
TMP_DIR=/tmp/flux/${ENVIRONMENT}/${CLUSTER_NAME}
FLUX_CONFIG_URL=https://raw.githubusercontent.com/hmcts/sds-flux-config/master
ISSUER_URL=$(az aks show -n ss-${ENVIRONMENT}-${CLUSTER_NAME}-aks -g ss-${ENVIRONMENT}-${CLUSTER_NAME}-rg --query "oidcIssuerProfile.issuerUrl" -otsv)

############################################################
# Functions
############################################################

# Install legacy aadpodidentity components
function install_aadpodidentity {
    echo "Creating admin namespace"

    if kubectl get ns | grep -q admin; then
        echo "already exists - continuing"
    else
        kubectl create ns admin
    fi

# Generate admin kustomization manifest
echo "Deploying aadPodIdentity - Generating manifest"
(
cat <<EOF
    apiVersion: kustomize.config.k8s.io/v1beta1
    namespace: admin
    kind: Kustomization
    commonLabels:
      k8s-app: aad-pod-id
    resources:
      - https://raw.githubusercontent.com/Azure/aad-pod-identity/v1.8.4/deploy/infra/deployment-rbac.yaml
    patches:
      - path: https://raw.githubusercontent.com/hmcts/sds-flux-config/master/apps/admin/aad-pod-identity/nmi-patch.yaml
      - path: https://raw.githubusercontent.com/hmcts/sds-flux-config/master/apps/admin/aad-pod-identity/mic-patch.yaml
EOF
) > "${TMP_DIR}/admin/kustomization.yaml"

# Apply
    echo "Deploying aadPodIdentity - Applying manifest" 
    ./kustomize build "${TMP_DIR}/admin" |  kubectl apply -f - 2>&1 | filter_kubectl_warnings
    
    CRDS="azureassignedidentities.aadpodidentity.k8s.io azureidentitybindings.aadpodidentity.k8s.io azureidentities.aadpodidentity.k8s.io azurepodidentityexceptions.aadpodidentity.k8s.io"
    for crd in $(echo "${CRDS}"); do
        kubectl -n flux-system wait --for condition=established --timeout=60s "customresourcedefinition.apiextensions.k8s.io/$crd"
    done
    
    kubectl apply -f https://raw.githubusercontent.com/hmcts/sds-flux-config/master/apps/admin/aad-pod-identity/mic-exception.yaml 2>&1 | filter_kubectl_warnings
    kubectl apply -f https://raw.githubusercontent.com/hmcts/sds-flux-config/master/apps/kube-system/aad-pod-identity/mic-exception.yaml 2>&1 | filter_kubectl_warnings
}


# Installs aso as prerequisite for WI federated credential for flux-system
function install_aso {
  # Download files in cert-manager directory
  echo "Deploying ASO - Downloading cert-manager"
  download_files "https://api.github.com/repos/hmcts/sds-flux-config/contents/apps/azureserviceoperator-system/cert-manager" "${TMP_DIR}/cert-manager"

  # Download files in aso directory
  echo "Deploying ASO - Downloading aso"
  download_files "https://api.github.com/repos/hmcts/sds-flux-config/contents/apps/azureserviceoperator-system/aso" "${TMP_DIR}/aso"

  # Download aso-controller-settings.yaml
  echo "Deploying ASO - Downloading aso-controller-settings"
  curl -sL "https://raw.githubusercontent.com/hmcts/sds-flux-config/master/apps/azureserviceoperator-system/${ENVIRONMENT}/base/aso-controller-settings.yaml" -o "${TMP_DIR}/aso-controller-settings.yaml"

  # Build and apply cert-manager
  echo "Deploying ASO - Applying cert-manager (may repeat 3 times)"
  ./kustomize build "${TMP_DIR}/cert-manager" > "${TMP_DIR}/cert-manager-result.yaml"
  kubectl apply -f "${TMP_DIR}/cert-manager-result.yaml" 2>&1 | filter_kubectl_warnings

  # Wait for cert-manager to be ready
  echo "Waiting for cert-manager to be ready..." 
  cert_manager_pod="$(kubectl get pod -n cert-manager --no-headers=true | awk '/cert-manager-webhook/{print $1}')"
  wait_for_k8s_resource "pod" "$cert_manager_pod" "cert-manager" "Ready"
  wait_for_k8s_resource "svc" "cert-manager-webhook" "cert-manager" ""
  wait_for_k8s_resource "mutatingwebhookconfiguration" "cert-manager-webhook" "" ""

  # Build and apply ASO
  echo "Deploying Azure Service Operator - Applying ASO"
  ./kustomize build "${TMP_DIR}/aso" > "${TMP_DIR}/aso-result.yaml"
  kubectl apply -f "${TMP_DIR}/aso-result.yaml" 2>&1 | filter_kubectl_warnings
  
  # Apply aso-controller-settings
  echo "Deploying Azure Service Operator - Applying aso-controller-settings"
  kubectl apply -f "${TMP_DIR}/aso-controller-settings.yaml" 2>&1 | filter_kubectl_warnings

  # Wait for CRDs to be in an established state
  # Wait for the FederatedIdentityCredential CRD
  echo "Waiting for FederatedIdentityCredential CRD to be established..."
  wait_for_crd "federatedidentitycredentials.managedidentity.azure.com"

  # Wait for the UserAssignedIdentity CRD
  echo "Waiting for UserAssignedIdentity CRD to be established..."
  wait_for_crd "userassignedidentities.managedidentity.azure.com"

  # Wait for the ResourceGroups CRD
  echo "Waiting for ResourceGroups CRD to be established..."
  wait_for_crd "resourcegroups.resources.azure.com"

  # Wait for ASO to be ready
  echo "Waiting for Azure Service Operator to be ready..." 
  aso_pod="$(kubectl get pod -n azureserviceoperator-system --no-headers=true | awk '/azureserviceoperator-controller-manager/{print $1}')"
  wait_for_k8s_resource "pod" "$aso_pod" "azureserviceoperator-system" "Ready" 150
  wait_for_k8s_resource "svc" "azureserviceoperator-webhook-service" "azureserviceoperator-system" ""
  wait_for_k8s_resource "mutatingwebhookconfiguration" "azureserviceoperator-mutating-webhook-configuration" "" ""
}


function flux_github_app_secret {
    echo " Kubectl Create GitHub App Secret"
    kubectl create secret generic guthub-app-credentials \
    --from-file=githubAppID=$AGENT_BUILDDIRECTORY/flux-github-app-id \
    --from-file=githubAppInstallationID=$AGENT_BUILDDIRECTORY/flux-github-app-installation-id \
    --from-file=githubAppPrivateKey=$AGENT_BUILDDIRECTORY/flux-github-app-private-key \
    --namespace flux-system \
    --dry-run=client -o yaml > "${TMP_DIR}/gotk/github-app-credentials.yaml"
}


# Installs flux components using workload identity
function install_flux {
# Generating WI ResourceGroup manifest
echo "Deploying Flux - Generating WI manifests"
download_files "https://api.github.com/repos/hmcts/sds-flux-config/contents/apps/flux-system/workload-identity" \
"${TMP_DIR}/gotk" \
"s|\${WI_CLUSTER}|$ENVIRONMENT-$CLUSTER_NAME|g" \
"s|\${ENVIRONMENT}|$ENVIRONMENT|g" \
"s|\${ISSUER_URL}|$ISSUER_URL|g"

# Generating Kustomization manifest
echo "Deploying Flux - Generating Kustomization manifest"
(
cat <<EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: flux-system
resources:
  - ${FLUX_CONFIG_URL}/apps/flux-system/base/gotk-components.yaml
  - github-app-credentials.yaml
  - workload-identity-federated-credential.yaml
  - workload-identity-ua-identity.yaml
  - workload-identity-rg.yaml
patches:
  - path: ${FLUX_CONFIG_URL}/apps/flux-system/base/patches/workload-identity-deployment.yaml
  - path: ${FLUX_CONFIG_URL}/apps/flux-system/serviceaccount/${ENVIRONMENT}.yaml
EOF
 ) > "${TMP_DIR}/gotk/kustomization.yaml"

# Apply
echo "Deploying Flux - Applying Kustomization manifest"
./kustomize build "${TMP_DIR}/gotk" |  kubectl apply -f - 2>&1 | filter_kubectl_warnings

# Wait for CRDs to be in an established state
# Wait for the GitRepositories CRD
echo "Waiting for GitRepositories CRD to be established..."
wait_for_crd "gitrepositories.source.toolkit.fluxcd.io"

# Wait for the Kustomizations CRD
echo "Waiting for Kustomizations CRD to be established..."
wait_for_crd "kustomizations.kustomize.toolkit.fluxcd.io"

# Apply kustomization and gitrepository declarations
(
cat <<EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: flux-system
resources:
  - ${FLUX_CONFIG_URL}/apps/flux-system/base/kustomize.yaml
  - ${FLUX_CONFIG_URL}/apps/flux-system/base/flux-config-gitrepo.yaml

patches:
  - path: ${FLUX_CONFIG_URL}/apps/flux-system/${ENVIRONMENT}/${CLUSTER_NAME}/kustomize.yaml
EOF
) > "${TMP_DIR}/flux-config/kustomization.yaml"

./kustomize build "${TMP_DIR}/flux-config" |  kubectl apply -f - 2>&1 | filter_kubectl_warnings
}


############################################################
# Main
############################################################

mkdir -p "${TMP_DIR}"/{gotk,flux-config,aso,admin,cert-manager}

install_kustomize
# Legacy - for aadPodIdentity (some namespaces still using aadPodIdentity)
install_aadpodidentity
install_aso
# Install flux components
flux_github_app_secret
install_flux

# Cleanup
rm -rf "${TMP_DIR}"