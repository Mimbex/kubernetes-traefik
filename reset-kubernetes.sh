#!/bin/bash

echo "🔄 Reset Kubernetes Cluster"
echo "============================"
echo ""
echo "⚠️  WARNING: This will completely reset Kubernetes!"
echo ""
echo "This will:"
echo "  ❌ Delete all pods, services, deployments"
echo "  ❌ Reset Kubernetes cluster"
echo "  ❌ Clean all data"
echo "  ❌ Remove CNI configuration"
echo ""

read -p "Are you sure you want to reset everything? (type 'yes' to confirm): " confirm

if [ "$confirm" != "yes" ]; then
    echo "❌ Reset cancelled"
    exit 0
fi

echo ""
echo "🗑️  Starting complete reset..."
echo ""

# Stop kubelet
echo "1️⃣ Stopping kubelet..."
sudo systemctl stop kubelet

# Reset Kubernetes
echo ""
echo "2️⃣ Resetting Kubernetes cluster..."
sudo kubeadm reset -f

# Clean iptables
echo ""
echo "3️⃣ Cleaning iptables rules..."
sudo iptables -F && sudo iptables -t nat -F && sudo iptables -t mangle -F && sudo iptables -X

# Remove CNI configuration
echo ""
echo "4️⃣ Removing CNI configuration..."
sudo rm -rf /etc/cni/net.d/*
sudo rm -rf /var/lib/cni/*

# Clean data directories
echo ""
echo "5️⃣ Cleaning data directories..."
sudo rm -rf /opt/odoo-data/*
sudo rm -rf /opt/odoo-extra-addons/*
sudo rm -rf /opt/postgresql-data/*
sudo rm -rf /opt/traefik-letsencrypt/*
sudo rm -rf /opt/backups/*
sudo rm -rf /var/lib/etcd/*

# Restart containerd
echo ""
echo "6️⃣ Restarting containerd..."
sudo systemctl restart containerd

# Wait a bit
sleep 5

# Reinitialize Kubernetes
echo ""
echo "7️⃣ Reinitializing Kubernetes cluster..."
POD_NETWORK_CIDR="10.244.0.0/16"
sudo kubeadm init --pod-network-cidr=$POD_NETWORK_CIDR --ignore-preflight-errors=NumCPU

if [ $? -ne 0 ]; then
    echo "❌ Kubernetes initialization failed"
    exit 1
fi

# Setup kubectl for current user
echo ""
echo "8️⃣ Configuring kubectl..."
mkdir -p $HOME/.kube
sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Remove taint from master node (single-node cluster)
echo ""
echo "9️⃣ Configuring single-node cluster..."
kubectl taint nodes --all node-role.kubernetes.io/control-plane- 2>/dev/null || true
kubectl taint nodes --all node-role.kubernetes.io/master- 2>/dev/null || true

# Install Flannel CNI
echo ""
echo "🔟 Installing Flannel CNI..."
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# Wait for system pods
echo ""
echo "⏳ Waiting for system pods to be ready (60 seconds)..."
sleep 60

# Show status
echo ""
echo "=========================================="
echo "✅ Kubernetes Reset Complete!"
echo "=========================================="
echo ""
kubectl get nodes
echo ""
kubectl get pods -A
echo ""
echo "🚀 Ready to install Odoo!"
echo "   Run: ./install-odoo.sh"
echo ""
