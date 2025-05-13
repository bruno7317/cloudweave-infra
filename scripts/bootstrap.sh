#!/bin/bash

# Update kubeconfig for your EKS cluster
aws eks update-kubeconfig --name cloudweave-eks-cluster --region ca-central-1

# Define path to argo manifests (relative to this script's directory)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARGO_PATH="$SCRIPT_DIR/../k8s/argo"

# Apply the manifests
kubectl apply -f "$ARGO_PATH/namespace.yaml"
kubectl apply -f "$ARGO_PATH/git-credentials.yaml"
kubectl apply -f "$ARGO_PATH/registries-config.yaml"
kubectl apply -f "$ARGO_PATH/image-updater-config.yaml"
kubectl apply -f "$ARGO_PATH/repo-public.yaml"

kubectl apply -n argocd -f "$ARGO_PATH/install.yaml"
kubectl apply -n argocd -f "$ARGO_PATH/image-updater.yaml"
kubectl apply -f "$ARGO_PATH/app-cloudweave.yaml"

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
kubectl annotate serviceaccount -n argocd argocd-image-updater eks.amazonaws.com/role-arn=arn:aws:iam::${ACCOUNT_ID}:role/argocd-image-updater-role