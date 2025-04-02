# shebannnngggggg
set -e

# Installs kustomize if not already installed
function install_kustomize {
    if [ -f ./kustomize ]; then
        echo "Kustomize installed"
    else
        #Install kustomize
        curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash -s ${KUSTOMIZE_VERSION}
    fi 

    echo "Kustomize version: $(./kustomize version)"
}

# Helper function to download files from a GitHub directory
function download_files {
  local url=$1
  local destination=$2
  shift 2  # Shift the first two arguments
  local sed_patterns=("$@")  # Capture remaining arguments as sed patterns

  curl -s "$url" | \
  grep -o '"download_url": "[^"]*' | \
  sed 's/"download_url": "//' | \
  while read -r file_url; do
    file_name=$(basename "$file_url")
    curl -s "$file_url" -o "${destination}/${file_name}"
    if [[ ${#sed_patterns[@]} -gt 0 ]]; then
      for pattern in "${sed_patterns[@]}"; do
        sed -i -e "$pattern" "${destination}/${file_name}"
      done
    fi
  done
}

# Wait for a CRD to be created and established
function wait_for_crd {
  local crd_name=$1
  local timeout=180  # Default timeout to 180 seconds
  local interval=10 # Default polling interval to 10 seconds

  echo "Waiting for CRD ${crd_name} to be created and established..."
  for ((i=0; i<${timeout}; i+=${interval})); do
    if kubectl get crd "${crd_name}" > /dev/null 2>&1; then
      echo "CRD ${crd_name} found. Waiting for it to be established..."
      kubectl wait --for condition=established --timeout=60s "customresourcedefinition.apiextensions.k8s.io/${crd_name}"
      if [ $? -eq 0 ]; then
        echo "CRD ${crd_name} is established."
        return 0
      else
        echo "CRD ${crd_name} is not yet established. Retrying..."
      fi
    else
      echo "CRD ${crd_name} not found. Retrying in ${interval} seconds..."
    fi
    sleep "${interval}"
  done

  echo "Error: CRD ${crd_name} was not created or established within ${timeout} seconds."
  return 1
}

# Wait for a Kubernetes resource to be ready
wait_for_k8s_resource() {
    local resource_type="$1"   # e.g., pod, svc, deployment, etc.
    local resource_name="$2"   # Name of the resource
    local namespace="$3"       # Namespace of the resource
    local condition="$4"       # Condition to wait for (optional)
    local timeout="${5:-120}"  # Timeout in seconds (default: 120)
    local sleep_interval=5
    local elapsed=0

    echo "Waiting for $resource_type/$resource_name in namespace $namespace..."

    while true; do
        case $resource_type in
            pod|deployment|statefulset|daemonset)
                if kubectl wait --for=condition=$condition $resource_type/$resource_name -n $namespace --timeout=5s 2>/dev/null; then
                    echo "$resource_type/$resource_name is ready."
                    return 0
                fi
                ;;
            svc)
                if [[ -n $(kubectl get endpoints $resource_name -n $namespace -o jsonpath='{.subsets}') ]]; then
                    echo "Service $resource_name has available endpoints."
                    return 0
                fi
                ;;
            mutatingwebhookconfiguration|validatingwebhookconfiguration)
                if kubectl get $resource_type | grep -q "$resource_name"; then
                    echo "$resource_type/$resource_name is available."
                    return 0
                fi
                ;;
            *)
                echo "Unsupported resource type: $resource_type"
                return 1
                ;;
        esac

        sleep $sleep_interval
        elapsed=$((elapsed + sleep_interval))

        if [[ $elapsed -ge $timeout ]]; then
            echo "Timeout: $resource_type/$resource_name did not become ready within ${timeout} seconds."
            echo "Exiting due to a resource not being ready."
            exit 1
        fi
    done
}