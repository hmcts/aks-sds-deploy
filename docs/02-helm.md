# Helm

Helm is a package manager for Kubernetes. Helm is made up of two components; Helm (the user client) and Tiller (the 
helm server).

It is strongly recommended installing Tiller using a secured configuration as this lives on the Kubernetes cluster.

This guide shows how to securely install Tiller to a RBAC enabled kubernetes cluster in Azure Kubernetes Service. This 
guid assumes you've no installation of Helm/Tiller on your kubernetes cluster.

**Prerequisites**

- A running kubernetes cluster on AKS with RBAC enabled
- Access to the kubernetes cluster (KUBECONFIG) either by;
  - Having the Service Principal that has access to the cluster
  - Being a member of a Azure AD group that has `cluster-admin` access

The goal is to ensure we;

- **Deploy Tiller in a namespace, restricted to deploying resources in another namespace**
- **Use SSL Between Helm and Tiller**

------

- Login to the kubernetes cluster
```
$ az aks get-credentials --resource-group $CLUSTER_RESOURCE_GROUP_NAME --name $CLUSTER_NAME
```

- Create a `namespace` and `service account`for Tiller
```
$ kubectl create namespace tiller
$ kubectl create serviceaccount tiller --namespace tiller
```

- Define a Role that allows Tiller to manage all resources in `<target namespace>` like in `tiller-rbac-role.yaml`:

```
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: tiller-manager-<target namespace>
  namespace: <target namespace>
rules:
- apiGroups: ["", "batch", "extensions", "apps"]
  resources: ["*"]
  verbs: ["*"]
```
```
$ kubectl create -f tiller-rbac-role.yaml
```

- Bind the service account to that role. like in `tiller-rbac-rolebinding.yaml`:

```
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: tiller-binding-<target namespace>
  namespace: <target namespace>
subjects:
- kind: ServiceAccount
  name: tiller
  namespace: tiller
roleRef:
  kind: Role
  name: tiller-manager-<target namespace>
  apiGroup: rbac.authorization.k8s.io
```
```
$ kubectl create -f tiller-rbac-rolebinding.yaml
```

- Grant Tiller access to read configmaps in `tiller` namespace so it can store release information. like in `tiller-rbac-namespace-role.yaml`:

```
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: tiller
  name: tiller-manager
rules:
- apiGroups: ["", "extensions", "apps"]
  resources: ["configmaps"]
  verbs: ["*"]
```
```
$ kubectl create -f tiller-rbac-namespace-role.yaml
```
- Bind the namespace role. like in `tiller-rbac-namespace-rolebinding.yaml`

```
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: tiller-binding
  namespace: tiller
subjects:
- kind: ServiceAccount
  name: tiller
  namespace: tiller
roleRef:
  kind: Role
  name: tiller-manager
  apiGroup: rbac.authorization.k8s.io
```
```
kubectl create -f tiller-rbac-namespace-rolebinding.yaml
```

- Generate certificates - CA, Helm, Tiller
```
$ openssl genrsa -out ./ca.key.pem 4096
$ openssl req -key ca.key.pem -new -x509 -days 7300 -sha256 -out ca.cert.pem -extensions v3_ca
$ openssl genrsa -out ./tiller.key.pem 4096
$ openssl genrsa -out ./helm.key.pem 4096
$ openssl req -key tiller.key.pem -new -sha256 -out tiller.csr.pem
$ openssl req -key helm.key.pem -new -sha256 -out helm.csr.pem
$ openssl x509 -req -CA ca.cert.pem -CAkey ca.key.pem -CAcreateserial -in tiller.csr.pem -out tiller.cert.pem -days 365
$ openssl x509 -req -CA ca.cert.pem -CAkey ca.key.pem -CAcreateserial -in helm.csr.pem -out helm.cert.pem  -days 365
```

- Deploy Tiller

With our certificates generated, we can now deploy `Tiller`
```
helm init --dry-run --debug --tiller-tls --tiller-tls-cert ./tiller.cert.pem --tiller-tls-key ./tiller.key.pem --tiller-tls-verify --tls-ca-cert ca.cert.pem --service-account tiller --tiller-namespace tiller

helm init --tiller-tls --tiller-tls-cert ./tiller.cert.pem --tiller-tls-key ./tiller.key.pem --tiller-tls-verify --tls-ca-cert ca.cert.pem --service-account tiller --tiller-namespace tiller
```

You can check it's correctly deployed - `kubectl -n tiller get deployment`

- Use Helm

With Tiller installed, we now need to configure our Helm client to access it using the TLS certificates we created;

```
cp ca.cert.pem $(helm home)/ca.pem
cp helm.cert.pem $(helm home)/cert.pem
cp helm.key.pem $(helm home)/key.pem
```

Quick check - `helm ls --tls --tiller-namespace tiller`
