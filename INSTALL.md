# Kubernetes Installation Guide

Easy installation guide for Kubernetes on any platform.

## 🚀 Quick Install

### macOS (Easiest)

```bash
chmod +x install-kubernetes-macos.sh
./install-kubernetes-macos.sh
```

This will install:
- ✅ Homebrew (if needed)
- ✅ kubectl
- ✅ minikube
- ✅ Docker Desktop (optional)

### Linux (Ubuntu/Debian/CentOS)

```bash
chmod +x install-kubernetes.sh
./install-kubernetes.sh
```

This will install:
- ✅ kubectl
- ✅ minikube
- ✅ Docker

## 📋 Manual Installation

### macOS

```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install kubectl and minikube
brew install kubectl minikube

# Install Docker Desktop (optional)
# Download from: https://www.docker.com/products/docker-desktop
```

### Ubuntu/Debian

```bash
# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

### CentOS/RHEL

```bash
# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Install Docker
sudo yum install -y docker
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER
```

## 🎯 Start Your First Cluster

### Option 1: Minikube (Local Development)

```bash
# Start cluster
minikube start

# Verify
kubectl cluster-info
kubectl get nodes

# Deploy Odoo
./scripts/deploy-all.sh
```

### Option 2: Docker Desktop Kubernetes (macOS/Windows)

```bash
# Enable Kubernetes in Docker Desktop settings
# Then verify:
kubectl cluster-info

# Deploy Odoo
./scripts/deploy-all.sh
```

### Option 3: Cloud Provider

#### Google Kubernetes Engine (GKE)

```bash
# Install gcloud CLI
curl https://sdk.cloud.google.com | bash

# Create cluster
gcloud container clusters create odoo-cluster \
  --num-nodes=3 \
  --machine-type=n1-standard-2

# Get credentials
gcloud container clusters get-credentials odoo-cluster

# Deploy Odoo
./scripts/deploy-all.sh
```

#### Amazon EKS

```bash
# Install eksctl
brew install eksctl  # macOS
# or download from: https://eksctl.io/

# Create cluster
eksctl create cluster \
  --name odoo-cluster \
  --region us-west-2 \
  --nodes 3

# Deploy Odoo
./scripts/deploy-all.sh
```

#### DigitalOcean Kubernetes

```bash
# Install doctl
brew install doctl  # macOS

# Authenticate
doctl auth init

# Create cluster
doctl kubernetes cluster create odoo-cluster \
  --count 3 \
  --size s-2vcpu-4gb

# Get credentials
doctl kubernetes cluster kubeconfig save odoo-cluster

# Deploy Odoo
./scripts/deploy-all.sh
```

## ✅ Verify Installation

```bash
# Check kubectl
kubectl version --client

# Check minikube (if using)
minikube version

# Check Docker
docker --version

# Check cluster
kubectl cluster-info
kubectl get nodes
```

## 🔧 Troubleshooting

### kubectl: command not found

```bash
# macOS
brew install kubectl

# Linux
sudo snap install kubectl --classic
```

### minikube start fails

```bash
# Delete and recreate
minikube delete
minikube start --driver=docker

# Or try different driver
minikube start --driver=virtualbox
```

### Docker permission denied

```bash
# Linux
sudo usermod -aG docker $USER
newgrp docker

# Or logout and login again
```

### Cluster not accessible

```bash
# Check cluster status
kubectl cluster-info

# Check context
kubectl config current-context

# Switch context (if multiple clusters)
kubectl config use-context minikube
```

## 📚 Next Steps

1. **Configure environment**
   ```bash
   cp .env.example .env
   nano .env
   ```

2. **Deploy Odoo stack**
   ```bash
   ./scripts/deploy-all.sh
   ```

3. **Setup backups**
   ```bash
   ./scripts/setup-backups.sh
   ```

4. **Access services**
   ```bash
   # Minikube
   minikube service odoo -n odoo
   
   # Cloud
   kubectl get svc traefik -n traefik
   ```

## 🎓 Learning Resources

- [Kubernetes Basics](https://kubernetes.io/docs/tutorials/kubernetes-basics/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Minikube Documentation](https://minikube.sigs.k8s.io/docs/)
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)

## 💡 Pro Tips

### Enable kubectl autocomplete

```bash
# Bash
echo 'source <(kubectl completion bash)' >> ~/.bashrc

# Zsh
echo 'source <(kubectl completion zsh)' >> ~/.zshrc
```

### Create kubectl alias

```bash
echo 'alias k=kubectl' >> ~/.zshrc
echo 'complete -F __start_kubectl k' >> ~/.zshrc
```

### Install k9s (Kubernetes CLI UI)

```bash
# macOS
brew install k9s

# Linux
curl -sS https://webinstall.dev/k9s | bash
```

---

**Easy Kubernetes Installation**
© 2025 Dustin Mimbela
