#!/bin/bash

echo "🚀 Complete Kubernetes + Odoo Installation"
echo "==========================================="
echo ""
echo "This script will install EVERYTHING you need:"
echo "  ✅ Kubernetes (kubeadm, kubectl, containerd)"
echo "  ✅ Initialize cluster"
echo "  ✅ Configure networking"
echo "  ✅ Deploy Odoo + PostgreSQL + Traefik"
echo "  ✅ Setup automated backups"
echo ""
echo "⏱️  Estimated time: 10-15 minutes"
echo ""

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "❌ This script needs sudo"
   echo "Run: sudo ./install-everything.sh"
   exit 1
fi

# Get the actual user
ACTUAL_USER=${SUDO_USER:-$USER}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "📋 Installing for user: $ACTUAL_USER"
echo "📁 Working directory: $SCRIPT_DIR"
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
echo "STEP 3/4: Configuring Odoo Environment"
echo "=========================================="
echo ""

# Check if .env exists
if [ ! -f "$SCRIPT_DIR/.env" ]; then
    echo "📝 Creating configuration file..."
    cp $SCRIPT_DIR/.env.example $SCRIPT_DIR/.env
    
    echo ""
    echo "⚠️  IMPORTANT: Please configure your domain"
    echo ""
    read -p "Enter your domain (e.g., odoo.example.com): " DOMAIN
    read -p "Enter your email for SSL certificates: " EMAIL
    
    # Update .env file
    sed -i "s/odoo.yourdomain.com/$DOMAIN/g" $SCRIPT_DIR/.env
    sed -i "s/your-email@example.com/$EMAIL/g" $SCRIPT_DIR/.env
    
    echo "✅ Configuration saved to .env"
else
    echo "✅ Using existing .env configuration"
fi

echo ""
echo "=========================================="
echo "STEP 4/4: Deploying Odoo Stack"
echo "=========================================="
echo ""

# Deploy as the actual user
cd $SCRIPT_DIR
su - $ACTUAL_USER -c "cd $SCRIPT_DIR && bash scripts/deploy-all.sh"

if [ $? -ne 0 ]; then
    echo "❌ Odoo deployment failed"
    exit 1
fi

echo ""
echo "=========================================="
echo "BONUS 1: Setting up Automated Backups"
echo "=========================================="
echo ""

su - $ACTUAL_USER -c "cd $SCRIPT_DIR && bash scripts/setup-backups.sh"

echo ""
echo "=========================================="
echo "BONUS 2: Installing Visual Tools"
echo "=========================================="
echo ""

# Install k9s
echo "📦 Installing k9s (Terminal UI)..."
bash $SCRIPT_DIR/scripts/install-k9s.sh

# Install Kubernetes Dashboard
echo ""
echo "📦 Installing Kubernetes Dashboard (Web UI)..."
su - $ACTUAL_USER -c "cd $SCRIPT_DIR && bash scripts/install-dashboard.sh"

echo ""
echo "=========================================="
echo "🎉 INSTALLATION COMPLETE!"
echo "=========================================="
echo ""
echo "✅ Kubernetes cluster running"
echo "✅ Odoo deployed"
echo "✅ PostgreSQL running"
echo "✅ Traefik with SSL configured"
echo "✅ Automated backups enabled"
echo ""
echo "📊 Cluster Status:"
su - $ACTUAL_USER -c "kubectl get pods --all-namespaces"

echo ""
echo "🌐 Access Information:"
echo "====================="
echo ""

# Get LoadBalancer IP
EXTERNAL_IP=$(su - $ACTUAL_USER -c "kubectl get svc traefik -n traefik -o jsonpath='{.status.loadBalancer.ingress[0].ip}'" 2>/dev/null)

if [ -z "$EXTERNAL_IP" ]; then
    # Try to get NodePort
    NODE_IP=$(hostname -I | awk '{print $1}')
    HTTP_PORT=$(su - $ACTUAL_USER -c "kubectl get svc traefik -n traefik -o jsonpath='{.spec.ports[?(@.name==\"web\")].nodePort}'" 2>/dev/null)
    HTTPS_PORT=$(su - $ACTUAL_USER -c "kubectl get svc traefik -n traefik -o jsonpath='{.spec.ports[?(@.name==\"websecure\")].nodePort}'" 2>/dev/null)
    
    echo "📍 Server IP: $NODE_IP"
    echo "🔗 HTTP Port: $HTTP_PORT"
    echo "🔗 HTTPS Port: $HTTPS_PORT"
    echo ""
    echo "⚠️  Configure your DNS:"
    echo "   Point your domain to: $NODE_IP"
    echo ""
else
    echo "📍 LoadBalancer IP: $EXTERNAL_IP"
    echo ""
    echo "⚠️  Configure your DNS:"
    echo "   Point your domain to: $EXTERNAL_IP"
    echo ""
fi

# Get domain from .env
DOMAIN=$(grep ODOO_DOMAIN $SCRIPT_DIR/.env | cut -d'=' -f2)
echo "🌐 Once DNS is configured, access:"
echo "   https://$DOMAIN"
echo ""

echo "📚 Useful Commands:"
echo "==================="
echo ""
echo "View all resources:"
echo "  kubectl get all -A"
echo ""
echo "View Odoo logs:"
echo "  kubectl logs -n odoo -l app=odoo -f"
echo ""
echo "Run manual backup:"
echo "  ./scripts/backup-now.sh"
echo ""
echo "Scale Odoo:"
echo "  kubectl scale deployment odoo -n odoo --replicas=3"
echo ""
echo "🎨 Visual Tools:"
echo "================"
echo ""
echo "Terminal UI (k9s):"
echo "  k9s"
echo ""
echo "Web Dashboard:"
echo "  ./scripts/open-dashboard.sh"
echo ""
echo "📖 Full documentation: cat README.md"
echo ""
echo "🎉 Enjoy your Odoo installation!"
