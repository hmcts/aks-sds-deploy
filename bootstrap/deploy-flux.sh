#!/usr/bin/env bash
set -e

############################################################
PROJECT="${1}"
ENVIRONMENT="${3}"
CLUSTER_NAME="${6}"
############################################################
HELM_OPERATOR_VER="1.2.0"
flux_repo_list="k8s/environments/${ENVIRONMENT}/cluster-${CLUSTER_NAME}\,k8s/environments/${ENVIRONMENT}/cluster-${CLUSTER_NAME}-overlay\,k8s/environments/${ENVIRONMENT}/common\,k8s/environments/${ENVIRONMENT}/common-overlay\,k8s/common"
AGENT_BUILDDIRECTORY=/tmp


############################################################
# Functions
############################################################

function flux_create_namespace {
    if [[ $(kubectl get ns | grep admin) ]]; then
        echo "already exists - continuing"
    else
        kubectl create ns admin
    fi
}

function pod_identity_components {
    echo "Deploying AAD Pod Identity"
    TMP_DIR=$AGENT_BUILDDIRECTORY/aad-pod-identity
    mkdir -p $TMP_DIR/admin

    if [[ $(kustomize version) ]]; then
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
  - https://raw.githubusercontent.com/Azure/aad-pod-identity/v1.7.4/deploy/infra/deployment-rbac.yaml
patchesStrategicMerge:
  - https://raw.githubusercontent.com/hmcts/shared-services-flux/master/k8s/namespaces/admin/aad-pod-identity/patches/aad-pod-id.yaml
EOF
) > "${TMP_DIR}/admin/kustomization.yaml"

# -----------------------------------------------------------

  ./kustomize build ${TMP_DIR}/admin |  kubectl apply -f -
  # workaround 'unable to recognize "STDIN": no matches for kind "AzurePodIdentityException" in version "aadpodidentity.k8s.io/v1"'
  sleep 1
  kubectl apply -f https://raw.githubusercontent.com/hmcts/shared-services-flux/master/k8s/namespaces/admin/aad-pod-identity/mic-exception.yaml
  kubectl apply -f https://raw.githubusercontent.com/hmcts/shared-services-flux/master/k8s/namespaces/kube-system/aad-pod-identity/mic-exception.yaml

  rm -rf ${TMP_DIR}
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


############################################################
# End of functions
############################################################

flux_create_namespace
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

