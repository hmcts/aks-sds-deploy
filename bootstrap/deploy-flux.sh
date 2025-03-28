#!/usr/bin/env bash
set -e

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

# Installs kustomize if not already installed
function install_kustomize {
    if [ -f ./kustomize ]; then
        echo "Kustomize installed"
    else
        #Install kustomize
        curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash -s ${KUSTOMIZE_VERSION}
    fi 
}


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
    ./kustomize build "${TMP_DIR}/admin" |  kubectl apply -f -
    
    CRDS="azureassignedidentities.aadpodidentity.k8s.io azureidentitybindings.aadpodidentity.k8s.io azureidentities.aadpodidentity.k8s.io azurepodidentityexceptions.aadpodidentity.k8s.io"
    for crd in $(echo "${CRDS}"); do
        kubectl -n flux-system wait --for condition=established --timeout=60s "customresourcedefinition.apiextensions.k8s.io/$crd"
    done
    
    kubectl apply -f https://raw.githubusercontent.com/hmcts/sds-flux-config/master/apps/admin/aad-pod-identity/mic-exception.yaml
    kubectl apply -f https://raw.githubusercontent.com/hmcts/sds-flux-config/master/apps/kube-system/aad-pod-identity/mic-exception.yaml
}


# Installs aso as prerequiste for WI federated credential for flux-system
function install_aso {
echo "Deploying ASO - Generating manifest"
(
cat <<EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - https://github.com/hmcts/sds-flux-config/tree/dtspo-24310-cert-manager/apps/azureserviceoperator-system/cert-manager
  - https://github.com/hmcts/sds-flux-config/tree/master/apps/azureserviceoperator-system/aso/
  - https://raw.githubusercontent.com/hmcts/sds-flux-config/master/apps/azureserviceoperator-system/${ENVIRONMENT}/base/aso-controller-settings.yaml
EOF
) > "${TMP_DIR}/aso/kustomization.yaml"

./kustomize build ${TMP_DIR}/aso > "${TMP_DIR}/aso/result.yaml"

# Apply - retries so that CRDs apply first and then manifests
echo "Deploying ASO - Applying manifest (may repeat 3 times)"
for i in {1..3}; do
  (kubectl apply -f ${TMP_DIR}/aso/result.yaml && break) || sleep 15;
done
}


function flux_ssh_git_key {
    ssh-keyscan -t ecdsa-sha2-nistp256 github.com > $AGENT_BUILDDIRECTORY/known_hosts
    echo " Kubectl Create Secret"
    kubectl create secret generic git-credentials \
    --from-file=identity=$AGENT_BUILDDIRECTORY/flux-ssh-git-key \
    --from-file=identity.pub=$AGENT_BUILDDIRECTORY/flux-ssh-git-key.pub \
    --from-file=known_hosts=$AGENT_BUILDDIRECTORY/known_hosts \
    --namespace flux-system \
    --dry-run=client -o yaml > "${TMP_DIR}/gotk/git-credentials.yaml"
}


# Installs flux components using workload identity
function flux_installation {
# Generating WI ResourceGroup manifest
echo "Deploying Flux - Generating WI ResourceGroup manifest"
(
cat <<EOF
apiVersion: resources.azure.com/v1api20200601
kind: ResourceGroup
metadata:
  name: genesis-rg
  namespace: flux-system
  annotations:
    serviceoperator.azure.com/reconcile-policy: detach-on-delete
spec:
  location: uksouth
  azureName: genesis-rg
EOF
) > "${TMP_DIR}/gotk/workload-identity-rg.yaml"

# Generating WI UserAssignedIdentity manifest
echo "Deploying Flux - Generating WI UserAssignedIdentity manifest"
(
cat <<EOF
apiVersion: managedidentity.azure.com/v1api20181130
kind: UserAssignedIdentity
metadata:
  name: aks-${ENVIRONMENT}-mi
  namespace: flux-system
  annotations:
    serviceoperator.azure.com/reconcile-policy: skip
spec:
  location: uksouth
  owner:
    name: genesis-rg
EOF
) > "${TMP_DIR}/gotk/workload-identity-ua-identity.yaml"

# Generating WI FederatedIdentityCredential manifest
echo "Deploying Flux - Generating WI FederatedIdentityCredential manifest"
(
cat <<EOF
apiVersion: managedidentity.azure.com/v1api20220131preview
kind: FederatedIdentityCredential
metadata:
  name: aks-${ENVIRONMENT}-${CLUSTER_NAME}-fic
  namespace: flux-system
spec:
  owner:
    name: aks-${ENVIRONMENT}-mi
  audiences:
    - api://AzureADTokenExchange
  issuer: ${ISSUER_URL}
  subject: system:serviceaccount:flux-system:kustomize-controller
EOF
) > "${TMP_DIR}/gotk/workload-identity-federated-credential.yaml"

# Generating Kustomization manifest
echo "Deploying Flux - Generating Kustomization manifest"
(
cat <<EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: flux-system
resources:
  - ${FLUX_CONFIG_URL}/apps/flux-system/base/gotk-components.yaml
  - git-credentials.yaml 
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
./kustomize build "${TMP_DIR}/gotk" |  kubectl apply -f -

# Wait for CRDs to be in an established state
kubectl -n flux-system wait --for condition=established --timeout=60s customresourcedefinition.apiextensions.k8s.io/gitrepositories.source.toolkit.fluxcd.io
kubectl -n flux-system wait --for condition=established --timeout=60s customresourcedefinition.apiextensions.k8s.io/kustomizations.kustomize.toolkit.fluxcd.io

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

./kustomize build "${TMP_DIR}/flux-config" |  kubectl apply -f -
}


############################################################
# Main
############################################################

mkdir -p "${TMP_DIR}"/{gotk,flux-config,aso,admin}

install_kustomize

# Legacy - for aadPodIdentity (some namespaces still using aadPodIdentity)
install_aadpodidentity

# Flux installation using workload identity
install_aso

# Install flux components
flux_ssh_git_key
flux_installation

# Cleanup
rm -rf "${TMP_DIR}"
