#!/bin/bash

kubectl create namespace gitlab-app

kubectl apply -f ../confs/argocd_manifest.yaml
kubectl port-forward -n gitlab-app svc/playground-gitlab 8889:8889 &

echo "ArgoCD application created!"
echo "Check status with: kubectl get applications -n argocd"
echo "Access the app with: curl http://localhost:8889"