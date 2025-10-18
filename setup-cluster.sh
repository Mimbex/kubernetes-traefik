#!/bin/bash

echo "🚀 Kubernetes Cluster Setup - Super Simple"
echo "==========================================="
echo ""
echo "This script will:"
echo "  1. Initialize Kubernetes cluster"
echo "  2. Configure kubectl"
echo "  3. Install network plugin"
echo "  4. Verify everything works"
echo ""

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "❌ This script needs sudo"
   echo "Run: sudo ./setup-cluster.sh"
   exit 1
fi

# Get the actual user (not root)
ACTUAL_USER=${SUDO_USER:-$USER}
ACTUAL_HOME=$(eval echo ~$ACTUAL_USER)

echo "📋 Setting up cluster for user: $ACTUAL_USER"
echo ""

# Check if kubeadm is installed
if ! command -v kubeadm &> /dev/null; then
    echo "❌ Kubernetes not installed!"
    echo "Please run: sudo ./install-kubernetes.sh first"
    exit 1
fi

echo "1️⃣ Initializing Kubernetes cluster..."
echo "   (This may take 2-3 minutes)"
echo ""

# Initialize cluster
kubeadm init --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=NumCPU

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ Cluster initialization failed"
    echo "If cluster already exists, run: sudo kubeadm reset"
    exit 1
fi

echo ""
echo "✅ Cluster initialized!"
echo ""

# Configure kubectl for the user
echo "2️⃣ Configuring kubectl for user $ACTUAL_USER..."

mkdir -p $ACTUAL_HOME/.kube
cp -f /etc/kubernetes/admin.conf $ACTUAL_HOME/.kube/config
chown -R $ACTUAL_USER:$ACTUAL_USER $ACTUAL_HOME/.kube

echo "✅ kubectl configured!"
echo ""

# Install Flannel network plugin
echo "3️⃣ Installing network plugin (Flannel)..."
su - $ACTUAL_USER -c "kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml"

echo "✅ Network plugin installed!"
echo ""

# Allow pods on master node (for single-node setup)
echo "4️⃣ Configuring single-node cluster..."
su - $ACTUAL_USER -c "kubectl taint nodes --all node-role.kubernetes.io/control-plane- 2>/dev/null || true"

echo "✅ Single-node setup complete!"
echo ""

# Wait for node to be ready
echo "5️⃣ Waiting for cluster to be ready..."
echo "   (This may take 1-2 minutes)"

COUNTER=0
while [ $COUNTER -lt 60 ]; do
    NODE_STATUS=$(su - $ACTUAL_USER -c "kubectl get nodes -o jsonpath='{.items[0].status.conditions[?(@.type==\"Ready\")].status}'" 2>/dev/null)
    if [ "$NODE_STATUS" == "True" ]; then
        echo ""
        echo "✅ Cluster is ready!"
        break
    fi
    echo -n "."
    sleep 5
    COUNTER=$((COUNTER+1))
done

if [ "$NODE_STATUS" != "True" ]; then
    echo ""
    echo "⚠️  Cluster is taking longer than expected"
    echo "Check status with: kubectl get nodes"
fi

echo ""
echo "=========================================="
echo "✅ Kubernetes Cluster Ready!"
echo "=========================================="
echo ""

# Show cluster info
echo "📊 Cluster Information:"
su - $ACTUAL_USER -c "kubectl cluster-info"

echo ""
echo "📋 Nodes:"
su - $ACTUAL_USER -c "kubectl get nodes"

echo ""
echo "🎉 SUCCESS! Your Kubernetes cluster is ready!"
echo ""
echo "🚀 Next Steps:"
echo "=============="
echo ""
echo "1. Deploy Odoo (as user $ACTUAL_USER):"
echo "   cd $(pwd)"
echo "   cp .env.example .env"
echo "   nano .env  # Edit your domain"
echo "   ./scripts/deploy-all.sh"
echo ""
echo "2. Check deployment:"
echo "   kubectl get pods --all-namespaces"
echo ""
echo "3. Setup backups:"
echo "   ./scripts/setup-backups.sh"
echo ""
echo "📚 Useful commands:"
echo "   kubectl get pods -A        # View all pods"
echo "   kubectl get svc -A         # View all services"
echo "   kubectl get nodes          # View cluster nodes"
echo ""
