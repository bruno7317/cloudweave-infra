#!/bin/bash

# Get the ArgoCD initial admin password (decoded)
echo "🔐 ArgoCD admin password:"
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 --decode
echo

# Forward localhost:8080 to ArgoCD server (port 443)
echo "🌐 Port forwarding ArgoCD UI to https://localhost:8080 ..."
kubectl port-forward svc/argocd-server -n argocd 8080:443