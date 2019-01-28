#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Create an AWS EKS cluster service account with kubectl utility
# 
# 
# For more details, please visit:
#   https://kubernetes.io/docs/reference/kubectl/overview/
#
# NOTE: All inputs are defined by external environment variables.
#       Optional variables have reasonable defaults, but you may override as needed.
#       See 'usage()' function below for environment variable descriptions.
#       Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# run kubectl command to create the eks service account cluster. ----------------------------------------------

echo "Creating EKS service account..."
kubectl create -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: appd-k8s
  namespace: default
EOF

echo "Binding EKS service account to cluster role..."
kubectl create -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: appd-k8s
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: appd-k8s
  namespace: default
EOF
