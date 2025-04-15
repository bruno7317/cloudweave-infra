aws eks update-kubeconfig --name cloudweave-eks-cluster --region ca-central-1

kubectl apply -f namespace.yaml

kubectl apply -n argocd -f install.yaml

kubectl apply -f app-cloudweave.yaml