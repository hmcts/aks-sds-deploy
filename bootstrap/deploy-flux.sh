#!/usr/bin/env bash
set -e

############################################################
PROJECT="${1}"
ENVIRONMENT="${3}"
CLUSTER_NAME="${6}"
############################################################
HELM_OPERATOR_VER="1.4.0"
flux_repo_list="k8s/environments/${ENVIRONMENT}/cluster-${CLUSTER_NAME}\,k8s/environments/${ENVIRONMENT}/cluster-${CLUSTER_NAME}-overlay\,k8s/environments/${ENVIRONMENT}/common\,k8s/environments/${ENVIRONMENT}/common-overlay\,k8s/common"
AGENT_BUILDDIRECTORY=/tmp

############################################################
# Functions
############################################################

function create_admin_namespace {
    if [[ $(kubectl get ns | grep admin) ]]; then
        echo "already exists - continuing"
    else
        kubectl create ns admin
    fi
}

function pod_identity_components {
    echo "Deploying AAD Pod Identity"
    mkdir -p $TMP_DIR/admin

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
  - https://raw.githubusercontent.com/hmcts/sds-flux-config/master/k8s/namespaces/admin/aad-pod-identity/patches/aad-pod-id.yaml
EOF
) > "${TMP_DIR}/admin/kustomization.yaml"

# -----------------------------------------------------------

    ./kustomize build ${TMP_DIR}/admin |  kubectl apply -f -
    
    CRDS="azureassignedidentities.aadpodidentity.k8s.io azureidentitybindings.aadpodidentity.k8s.io azureidentities.aadpodidentity.k8s.io azurepodidentityexceptions.aadpodidentity.k8s.io"
    for crd in $(echo $CRDS); do
        kubectl -n flux-system wait --for condition=established --timeout=60s "customresourcedefinition.apiextensions.k8s.io/$crd"
    done
    
    kubectl apply -f https://raw.githubusercontent.com/hmcts/sds-flux-config/master/k8s/namespaces/admin/aad-pod-identity/mic-exception.yaml
    kubectl apply -f https://raw.githubusercontent.com/hmcts/sds-flux-config/master/k8s/namespaces/kube-system/aad-pod-identity/mic-exception.yaml

}

function pod_identity_flux_sop_setup {
    echo "SOPS MI Role"
    cat ../kubernetes/charts/aad-pod-identities/aks-sops-role.yaml | \
    sed -e 's@MI_RESOURCE_ID@'"$(az identity show --resource-group 'genesis-rg' --name aks-${ENVIRONMENT}-mi --query 'id' | sed 's/"//g')"'@' | \
    sed -e 's@MI_CLIENTID@'"$(az identity show --resource-group 'genesis-rg' --name aks-${ENVIRONMENT}-mi --query 'clientId' | sed 's/"//g')"'@' | \
    kubectl apply -f -
    
}

function helm_add_repo {
    echo "Adding flux repo"
    helm repo add fluxcd https://charts.fluxcd.io \
    --namespace admin
}

function helm_apply_crd {
    echo "Kubectl apply fluxcd"
    kubectl apply -f https://raw.githubusercontent.com/fluxcd/helm-operator/${HELM_OPERATOR_VER}/deploy/crds.yaml
}

function flux_ssh_git_key {
    echo " Kubectl Create Secret"
    kubectl create secret generic flux-git-deploy \
    --from-file=identity=$AGENT_BUILDDIRECTORY/flux-ssh-git-key \
    --namespace admin \
    --dry-run=client -o yaml | kubectl apply -f -
}

function flux_install {
    echo "helm install"
    helm upgrade -i flux fluxcd/flux -f ../kubernetes/charts/fluxcd/flux-values.yaml \
    --set git.path=${1}\
    --set git.label=${2}-${CLUSTER_NAME} \
    --set helm.versions=${3} \
    --namespace admin
}

function flux_helm_operator_install {
    echo "helm install helm operator"
    helm upgrade -i helm-operator fluxcd/helm-operator --wait -f ../kubernetes/charts/fluxcd/helm-operator-values.yaml \
    --namespace admin
}

function flux_v2_pod_identity_sops_setup {
    echo "Creating Pod Identity"
    cat ../kubernetes/charts/aad-pod-identities/aks-sops-role.yaml | \
    sed -e 's@MI_RESOURCE_ID@'"$(az identity show --resource-group 'genesis-rg' --name aks-${ENVIRONMENT}-mi --query 'id' | sed 's/"//g')"'@' | \
    sed -e 's@MI_CLIENTID@'"$(az identity show --resource-group 'genesis-rg' --name aks-${ENVIRONMENT}-mi --query 'clientId' | sed 's/"//g')"'@' | \
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
    --dry-run=client -o yaml > ${TMP_DIR}/gotk/git-credentials.yaml
}

function flux_v2_installation {

    FLUX_CONFIG_URL=https://raw.githubusercontent.com/hmcts/sds-flux-config/master
    

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
    ./kustomize build ${TMP_DIR}/gotk |  kubectl apply -f -

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
    ./kustomize build ${TMP_DIR}/flux-config |  kubectl apply -f -


}

############################################################
# End of functions
############################################################

FLUX_V2_CLUSTERS=( 'ptl' 'sbox' 'dev' 'stg' 'prod' 'ithc' 'demo')

if [[ " ${FLUX_V2_CLUSTERS[*]} " =~ " ${ENVIRONMENT} " ]]; then
    TMP_DIR=/tmp/flux/${ENVIRONMENT}/${CLUSTER_NAME}
    mkdir -p $TMP_DIR/{gotk,flux-config}
    create_admin_namespace
    pod_identity_components
    flux_v2_pod_identity_sops_setup
    flux_v2_ssh_git_key
    flux_v2_installation
fi

FLUX_V1_CLUSTERS=( 'stg' 'test' 'prod' 'ptlsbox' 'ptl')

if [[ " ${FLUX_V1_CLUSTERS[*]} " =~ " ${ENVIRONMENT} " ]]; then
    TMP_DIR=$AGENT_BUILDDIRECTORY/aad-pod-identity
    mkdir -p $TMP_DIR/admin
    create_admin_namespace
    pod_identity_components
    pod_identity_flux_sop_setup
    # give a bit of time for identity to sync so that flux start's correctly first time
    sleep 60
    helm_add_repo
    echo "****  repo added ****"
    helm_apply_crd ${HELM_OPERATOR_VER}
    flux_ssh_git_key
    echo "****  ssh key added ****"
    flux_install ${flux_repo_list} ${ENVIRONMENT} v3
    echo "****  flux is now installed ****"
    flux_helm_operator_install
    echo "**** helm operator is now installed ****"
fi

rm -rf ${TMP_DIR}
