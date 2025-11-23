#!/bin/bash

echo "Installing required packages..."

sudo apt-get update

if ! command -v docker &> /dev/null; then
    echo "Installing Docker on Debian..."
    
    sudo apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
    sudo usermod -aG docker $USER
    
    sudo systemctl start docker
    sudo systemctl enable docker
    
    echo "Docker installed successfully!"
    echo "Please log out and log back in for group changes to take effect, or run: newgrp docker"
fi

if ! command -v kubectl &> /dev/null; then
    echo "Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
fi

if ! command -v k3d &> /dev/null; then
    echo "Installing k3d..."
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
fi

echo ""
echo "Installation complete!"
echo ""
echo "Docker version:"
docker --version 2>/dev/null || echo "Docker installed but needs group permissions"
echo ""
echo "kubectl version:"
kubectl version --client
echo ""
echo "k3d version:"
k3d version