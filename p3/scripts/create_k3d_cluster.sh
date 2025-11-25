#!/bin/bash

k3d cluster create mycluster \
  --port 8888:8888@loadbalancer \
  --port 8889:8889@loadbalancer \
  --port 8080:80@loadbalancer \
  --port 8443:443@loadbalancer

echo "Waiting for cluster to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=60s

echo "Cluster created successfully!"
kubectl get nodes