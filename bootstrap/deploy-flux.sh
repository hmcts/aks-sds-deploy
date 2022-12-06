#!/usr/bin/env bash
set -ex

############################################################
ENVIRONMENT="${3}"
CLUSTER_NAME="${6}"
AGENT_BUILDDIRECTORY=/tmp

############################################################
# Functions
############################################################

function create_admin_namespace {
    if kubectl get ns | grep -q admin; then
        echo "already exists - continuing"
    else
        kubectl create ns admin
    fi
}

function pod_identity_components {
    echo "Deploying AAD Pod Identity"
    mkdir -p "${TMP_DIR}/admin"

    if [ -f ./kustomize ]; then
        echo "Kustomize installed"
    else
        #Install kustomize
        curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
    fi 
    # -----------------------------------------------------------
(
cat <<EOF
apiVersion: kustomize.config.k8s.io/v1beta1
namespace: admin
kind: Kustomization
commonLabels:
  k8s-app: aad-pod-id
resources:
  - https://raw.githubusercontent.com/Azure/aad-pod-identity/v1.8.4/deploy/infra/deployment-rbac.yaml
patchesStrategicMerge:
  - https://raw.githubusercontent.com/hmcts/sds-flux-config/DTSPO-11343-nameoverrides/apps/admin/aad-pod-identity/aad-pod-id-patch.yaml
EOF
) > "${TMP_DIR}/admin/kustomization.yaml"

# -----------------------------------------------------------

    ./kustomize build "${TMP_DIR}/admin" |  kubectl apply -f -
    
    CRDS="azureassignedidentities.aadpodidentity.k8s.io azureidentitybindings.aadpodidentity.k8s.io azureidentities.aadpodidentity.k8s.io azurepodidentityexceptions.aadpodidentity.k8s.io"
    for crd in $(echo "${CRDS}"); do
        kubectl -n flux-system wait --for condition=established --timeout=60s "customresourcedefinition.apiextensions.k8s.io/$crd"
    done
    
    kubectl apply -f https://raw.githubusercontent.com/hmcts/sds-flux-config/DTSPO-11343-nameoverrides/apps/admin/aad-pod-identity/mic-exception.yaml
    kubectl apply -f https://raw.githubusercontent.com/hmcts/sds-flux-config/DTSPO-11343-nameoverrides/apps/kube-system/aad-pod-identity/mic-exception.yaml

}

function flux_ssh_git_key {
    echo " Kubectl Create Secret"
    kubectl create secret generic flux-git-deploy \
    --from-file=identity=$AGENT_BUILDDIRECTORY/flux-ssh-git-key \
    --namespace admin \
    --dry-run=client -o yaml | kubectl apply -f -
}

function flux_v2_pod_identity_sops_setup {
    echo "Creating Pod Identity"
    cat ../kubernetes/charts/aad-pod-identities/aks-sops-role.yaml | \
    sed -e 's@MI_RESOURCE_ID@'"$(az identity show --resource-group 'genesis-rg' --name "aks-${ENVIRONMENT}-mi" --query 'id' | sed 's/"//g')"'@' | \
    sed -e 's@MI_CLIENTID@'"$(az identity show --resource-group 'genesis-rg' --name "aks-${ENVIRONMENT}-mi" --query 'clientId' | sed 's/"//g')"'@' | \
    sed -e 's@admin@flux-system@' > ${TMP_DIR}/gotk/aks-sops-aadpodidentity.yaml

    if [ -f ./kustomize ]; then
        echo "Kustomize installed"
    else
        #Install kustomize
        curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
    fi 

}

function flux_v2_ssh_git_key {
    ssh-keyscan -t ecdsa-sha2-nistp256 github.com > $AGENT_BUILDDIRECTORY/known_hosts
    echo " Kubectl Create Secret"
    kubectl create secret generic git-credentials \
    --from-file=identity=$AGENT_BUILDDIRECTORY/flux-ssh-git-key \
    --from-file=identity.pub=$AGENT_BUILDDIRECTORY/flux-ssh-git-key.pub \
    --from-file=known_hosts=$AGENT_BUILDDIRECTORY/known_hosts \
    --namespace flux-system \
    --dry-run=client -o yaml > "${TMP_DIR}/gotk/git-credentials.yaml"
}

function flux_v2_installation {
    FLUX_CONFIG_URL=https://raw.githubusercontent.com/hmcts/sds-flux-config/DTSPO-11343-nameoverrides
# -----------------------------------------------------------
# Deploy components and CRDs
    (
    cat <<EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: flux-system
resources:
- ${FLUX_CONFIG_URL}/apps/flux-system/base/gotk-components.yaml
- git-credentials.yaml
- aks-sops-aadpodidentity.yaml

patchesStrategicMerge:
- ${FLUX_CONFIG_URL}/apps/flux-system/base/patches/kustomize-controller-patch.yaml
EOF
    ) > "${TMP_DIR}/gotk/kustomization.yaml"
# -----------------------------------------------------------
    ./kustomize build "${TMP_DIR}/gotk" |  kubectl apply -f -

    # Wait for CRDs to be in an established state
    kubectl -n flux-system wait --for condition=established --timeout=60s customresourcedefinition.apiextensions.k8s.io/gitrepositories.source.toolkit.fluxcd.io
    kubectl -n flux-system wait --for condition=established --timeout=60s customresourcedefinition.apiextensions.k8s.io/kustomizations.kustomize.toolkit.fluxcd.io
# -----------------------------------------------------------

# -----------------------------------------------------------
# Apply kustomization and gitrepository declarations
    (
    cat <<EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: flux-system
resources:
- ${FLUX_CONFIG_URL}/apps/flux-system/base/kustomize.yaml
- ${FLUX_CONFIG_URL}/apps/flux-system/base/flux-config-gitrepo.yaml

patchesStrategicMerge:
- ${FLUX_CONFIG_URL}/apps/flux-system/${ENVIRONMENT}/${CLUSTER_NAME}/kustomize.yaml
EOF
    ) > "${TMP_DIR}/flux-config/kustomization.yaml"
# -----------------------------------------------------------
    ./kustomize build "${TMP_DIR}/flux-config" |  kubectl apply -f -

}

############################################################
# End of functions
############################################################

TMP_DIR=/tmp/flux/${ENVIRONMENT}/${CLUSTER_NAME}
mkdir -p "${TMP_DIR}"/{gotk,flux-config}

# Install pod identity components
create_admin_namespace
pod_identity_components

# Install flux components
flux_v2_pod_identity_sops_setup
flux_v2_ssh_git_key
flux_v2_installation

# Cleanup
rm -rf "${TMP_DIR}"
