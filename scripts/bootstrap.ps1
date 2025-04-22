aws eks update-kubeconfig --name cloudweave-eks-cluster --region ca-central-1

$argoPath = Join-Path $PSScriptRoot "..\k8s\argo"

kubectl apply -f "$argoPath\namespace.yaml"
kubectl apply -f "$argoPath\git-credentials.yaml"
kubectl apply -f "$argoPath\image-updater-config.yaml"
kubectl apply -f "$argoPath\repo-public.yaml"

kubectl apply -n argocd -f "$argoPath\install.yaml"
kubectl apply -n argocd -f "$argoPath\image-updater.yaml"
kubectl apply -f "$argoPath\app-cloudweave.yaml"