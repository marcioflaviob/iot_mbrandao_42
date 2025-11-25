#!/bin/bash

echo "Installing GitLab in Kubernetes using Helm..."

# Check if kubectl is available
if ! kubectl version --client &> /dev/null; then
    echo "ERROR: kubectl is not installed or not in PATH"
    exit 1
fi

# Check if helm is available
if ! helm version &> /dev/null; then
    echo "Helm not found. Installing Helm..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    
    if ! helm version &> /dev/null; then
        echo "ERROR: Failed to install Helm"
        exit 1
    fi
    echo "Helm installed successfully!"
fi

echo "Creating gitlab namespace..."
kubectl create namespace gitlab --dry-run=client -o yaml | kubectl apply -f -

echo "Adding GitLab Helm repository..."
helm repo add gitlab https://charts.gitlab.io/
helm repo update

echo "Installing GitLab with minimal configuration (this may take 5-10 minutes)..."
helm install gitlab gitlab/gitlab \
  --namespace gitlab \
  --set global.hosts.domain=gitlab.local \
  --set global.hosts.externalIP=127.0.0.1 \
  --set certmanager-issuer.email=admin@gitlab.local \
  --set global.ingress.configureCertmanager=false \
  --set gitlab-runner.install=false \
  --set prometheus.install=false \
  --set global.edition=ce \
  --set nginx-ingress.enabled=false \
  --set global.ingress.enabled=false \
  --set postgresql.metrics.enabled=false \
  --set redis.metrics.enabled=false \
  --set gitlab.gitaly.resources.requests.memory=200Mi \
  --set gitlab.gitaly.resources.requests.cpu=100m \
  --set gitlab.webservice.resources.requests.memory=300Mi \
  --set gitlab.webservice.resources.requests.cpu=200m \
  --set gitlab.webservice.minReplicas=1 \
  --set gitlab.webservice.maxReplicas=1 \
  --set gitlab.sidekiq.resources.requests.memory=300Mi \
  --set gitlab.sidekiq.resources.requests.cpu=100m \
  --set gitlab.sidekiq.minReplicas=1 \
  --set gitlab.sidekiq.maxReplicas=1 \
  --set postgresql.resources.requests.memory=200Mi \
  --set postgresql.resources.requests.cpu=100m \
  --set redis.resources.requests.memory=100Mi \
  --set redis.resources.requests.cpu=50m \
  --set gitlab.gitlab-shell.resources.requests.memory=50Mi \
  --set gitlab.gitlab-shell.resources.requests.cpu=50m \
  --set registry.enabled=false \
  --set global.minio.enabled=true \
  --set minio.resources.requests.memory=128Mi \
  --set minio.resources.requests.cpu=50m \
  --timeout 15m

echo ""
echo "Waiting for GitLab pods to be ready..."
kubectl wait --for=condition=ready pod -l app=webservice -n gitlab --timeout=600s

echo ""
echo "Creating LoadBalancer service for GitLab..."
kubectl apply -f ../confs/gitlab_manifest.yaml

helm upgrade gitlab gitlab/gitlab \
  --namespace gitlab \
  --reuse-values \
  --set global.hosts.domain=172.18.0.3.nip.io \
  --set global.hosts.https=false \
  --timeout 10m

echo ""
echo "==================================="
echo "GitLab Installation Complete!"
echo "==================================="
echo ""
echo "GitLab URL: http://172.18.0.3:8090"
echo ""
echo "==================================="
echo "Login Information:"
echo "==================================="
echo "Username: root"
echo -n "Password: "
kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -o jsonpath='{.data.password}' | base64 -d
#wNRmURe755NeRTkYkPKiJK9GZ6Ypgpnc9qtfvCxNC5mAOi9WmTAA70oiSJPuBzzW
echo ""
echo ""
echo "==================================="
echo "Next Steps:"
echo "==================================="
echo "1. Access GitLab at http://172.18.0.3:8090:8090"
echo "2. Login with root and the password above"
echo "3. Create a new project"
echo "4. Push your code to GitLab"
echo "5. Update ArgoCD to use: http://gitlab-webservice.gitlab.svc.cluster.local:8181/root/your-project.git"
echo "==================================="
