#!/bin/bash

kubectl create namespace argocd

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

echo "ArgoCD is ready!"
echo "Initial admin password:"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo ""

echo "Setting up port-forward for ArgoCD UI on http://localhost:8080"
kubectl port-forward svc/argocd-server -n argocd 8080:443 &

echo "ArgoCD UI will be available at https://localhost:8080"
echo "Username: admin"