aws eks update-kubeconfig --name cloudweave-eks-cluster --region ca-central-1

$argoPath = Join-Path $PSScriptRoot "..\k8s\argo"

kubectl apply -f "$argoPath\namespace.yaml"
kubectl apply -n argocd -f "$argoPath\install.yaml"
kubectl apply -f "$argoPath\app-cloudweave.yaml"