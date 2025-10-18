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

su - $ACTUAL_USER -c "cd $SCRIPT_DIR && bash scripts/install-dashboard.sh"

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
echo "2️⃣ Web Dashboard - Full Featured:"
echo "   ./scripts/open-dashboard.sh"
echo ""
echo "   Or manually:"
echo "   kubectl -n kubernetes-dashboard create token admin-user"
echo "   kubectl proxy"
echo "   # Then open: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"
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
echo "🚀 Next Steps"
echo "=========================================="
echo ""
echo "Your Kubernetes cluster is ready!"
echo ""
echo "To deploy Odoo + PostgreSQL + Traefik:"
echo "  1. Configure your domain:"
echo "     cp .env.example .env"
echo "     nano .env"
echo ""
echo "  2. Deploy Odoo stack:"
echo "     ./install-odoo.sh"
echo ""
echo "📖 Documentation:"
echo "  - README.md - Full documentation"
echo "  - VISUAL-TOOLS.md - Visual tools guide"
echo "  - SIMPLE-INSTALL.md - Simple installation guide"
echo ""
echo "🎉 Happy Kubernetes!"
