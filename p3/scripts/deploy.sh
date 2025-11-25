#!/bin/bash

kubectl create namespace dev

kubectl apply -f ../confs/argocd_manifest.yaml
kubectl port-forward svc/argocd-server -n argocd 8081:443 &

echo "ArgoCD application created!"
echo "Check status with: kubectl get applications -n argocd"
echo "Access the app with: curl http://localhost:8888"