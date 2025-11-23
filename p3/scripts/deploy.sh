#!/bin/bash

kubectl create namespace dev

kubectl apply -f ../confs/argocd_manifest.yaml

echo "ArgoCD application created!"
echo "Check status with: kubectl get applications -n argocd"
echo "Access the app with: curl http://localhost:8888"