#!/bin/bash

echo "🚀 Complete Kubernetes Installation with Dashboard"
echo "==================================================="
echo ""
echo "This script will install:"
echo "  ✅ Kubernetes (kubeadm, kubectl, containerd)"
echo "  ✅ Initialize cluster"
echo "  ✅ Configure networking"
echo "  ✅ Kubernetes Dashboard (Web UI)"
echo "  ✅ k9s (Terminal UI)"
echo ""
echo "⏱️  Estimated time: 5-8 minutes"
echo ""

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "❌ This script needs sudo"
   echo "Run: sudo ./install-kubernetes-complete.sh"
   exit 1
fi

# Get the actual user
ACTUAL_USER=${SUDO_USER:-$USER}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "📋 Installing for user: $ACTUAL_USER"
echo ""

read -p "Continue with installation? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Installation cancelled"
    exit 0
fi

echo ""
echo "=========================================="
echo "STEP 1/4: Installing Kubernetes"
echo "=========================================="
echo ""

# Run Kubernetes installation
bash $SCRIPT_DIR/install-kubernetes.sh

if [ $? -ne 0 ]; then
    echo "❌ Kubernetes installation failed"
    exit 1
fi

echo ""
echo "=========================================="
echo "STEP 2/4: Setting up Kubernetes Cluster"
echo "=========================================="
echo ""

# Run cluster setup
bash $SCRIPT_DIR/setup-cluster.sh

if [ $? -ne 0 ]; then
    echo "❌ Cluster setup failed"
    exit 1
fi

echo ""
echo "=========================================="
echo "STEP 3/4: Installing k9s (Terminal UI)"
echo "=========================================="
echo ""

bash $SCRIPT_DIR/scripts/install-k9s.sh

echo ""
echo "=========================================="
echo "STEP 4/4: Installing Kubernetes Dashboard"
echo "=========================================="
echo ""

echo "📦 Installing Kubernetes Dashboard (Web UI)..."
su - $ACTUAL_USER -c "cd $SCRIPT_DIR && bash scripts/install-dashboard.sh"

echo ""
echo "🌐 Exposing Dashboard to external access..."
su - $ACTUAL_USER -c "cd $SCRIPT_DIR && bash scripts/expose-dashboard.sh"

echo ""
echo "=========================================="
echo "🎉 KUBERNETES INSTALLATION COMPLETE!"
echo "=========================================="
echo ""
echo "✅ Kubernetes cluster running"
echo "✅ Network configured"
echo "✅ k9s installed (Terminal UI)"
echo "✅ Dashboard installed (Web UI)"
echo ""

# Show cluster info
echo "📊 Cluster Status:"
su - $ACTUAL_USER -c "kubectl get nodes"

echo ""
echo "📋 All Pods:"
su - $ACTUAL_USER -c "kubectl get pods --all-namespaces"

echo ""
echo "=========================================="
echo "🎨 Visual Tools Available"
echo "=========================================="
echo ""
echo "1️⃣ Terminal UI (k9s) - Quick and Fast:"
echo "   k9s"
echo ""
echo "2️⃣ Web Dashboard - Access from Browser:"
echo ""
NODEPORT=$(su - $ACTUAL_USER -c "kubectl get svc kubernetes-dashboard -n kubernetes-dashboard -o jsonpath='{.spec.ports[0].nodePort}'")
SERVER_IP=$(hostname -I | awk '{print $1}')
echo "   🌐 Dashboard URL:"
echo "   https://$SERVER_IP:$NODEPORT"
echo ""
echo "   🔑 Access Token:"
echo ""
TOKEN=$(su - $ACTUAL_USER -c "kubectl -n kubernetes-dashboard create token admin-user")
echo "   $TOKEN"
echo ""
echo "   ⚠️  Accept security warning in browser (self-signed certificate)"
echo ""
echo "   📋 Copy the token above and paste it in the dashboard login"
echo ""

echo "=========================================="
echo "📚 Useful Commands"
echo "=========================================="
echo ""
echo "View all resources:"
echo "  kubectl get all -A"
echo ""
echo "View nodes:"
echo "  kubectl get nodes"
echo ""
echo "View pods:"
echo "  kubectl get pods -A"
echo ""
echo "View services:"
echo "  kubectl get svc -A"
echo ""
echo "Describe a resource:"
echo "  kubectl describe pod <pod-name> -n <namespace>"
echo ""
echo "View logs:"
echo "  kubectl logs <pod-name> -n <namespace> -f"
echo ""

echo "=========================================="
echo "🎉 Your Kubernetes Cluster is Ready!"
echo "=========================================="
echo ""
echo "✅ Cluster running and healthy"
echo "✅ Visual monitoring tools installed"
echo "✅ Dashboard accessible from browser"
echo ""
echo "📖 Documentation:"
echo "  - README.md - Full documentation"
echo ""
echo "🎉 Happy Kubernetes!"
