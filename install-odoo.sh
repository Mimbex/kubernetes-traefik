#!/bin/bash

echo "🚀 Complete Odoo Stack Installation"
echo "===================================="
echo ""
echo "This script will install:"
echo "  ✅ Kubernetes (if not present)"
echo "  ✅ Odoo 19"
echo "  ✅ PostgreSQL 17"
echo "  ✅ Traefik with SSL"
echo "  ✅ Automated Backups"
echo ""
echo "⏱️  Estimated time: 5-15 minutes (depending on what's already installed)"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if kubectl is available and cluster is running
if ! command -v kubectl &> /dev/null || ! kubectl cluster-info &> /dev/null; then
    echo "⚠️  Kubernetes not detected!"
    echo ""
    echo "Installing Kubernetes cluster first..."
    echo ""
    
    # Check if install script exists
    if [ ! -f "$SCRIPT_DIR/install-kubernetes-complete.sh" ]; then
        echo "❌ install-kubernetes-complete.sh not found!"
        echo "Please run from the correct directory."
        exit 1
    fi
    
    # Make executable and run
    chmod +x "$SCRIPT_DIR/install-kubernetes-complete.sh"
    
    # Check if running as root
    if [ "$EUID" -ne 0 ]; then
        echo "🔐 Kubernetes installation requires root privileges."
        echo "Running with sudo..."
        sudo "$SCRIPT_DIR/install-kubernetes-complete.sh"
    else
        "$SCRIPT_DIR/install-kubernetes-complete.sh"
    fi
    
    # Verify installation
    if ! kubectl cluster-info &> /dev/null; then
        echo "❌ Kubernetes installation failed!"
        exit 1
    fi
    
    echo ""
    echo "✅ Kubernetes installed successfully!"
    echo ""
    sleep 2
fi

echo "✅ Kubernetes cluster detected"
echo ""

# Check if .env exists
if [ ! -f "$SCRIPT_DIR/.env" ]; then
    echo "📝 Creating configuration file..."
    cp $SCRIPT_DIR/.env.example $SCRIPT_DIR/.env
    
    echo ""
    echo "⚠️  IMPORTANT: Configure your domain and email"
    echo ""
    read -p "Enter your domain (e.g., odoo.example.com): " DOMAIN
    read -p "Enter your email for SSL certificates: " EMAIL
    
    # Update .env file
    sed -i "s/odoo.yourdomain.com/$DOMAIN/g" $SCRIPT_DIR/.env
    sed -i "s/your-email@example.com/$EMAIL/g" $SCRIPT_DIR/.env
    
    echo ""
    echo "✅ Configuration saved to .env"
    echo ""
    read -p "Press Enter to continue..."
else
    echo "✅ Using existing .env configuration"
    
    # Show current config
    DOMAIN=$(grep ODOO_DOMAIN $SCRIPT_DIR/.env | cut -d'=' -f2)
    EMAIL=$(grep LETSENCRYPT_EMAIL $SCRIPT_DIR/.env | cut -d'=' -f2)
    
    echo ""
    echo "📋 Current configuration:"
    echo "   Domain: $DOMAIN"
    echo "   Email: $EMAIL"
    echo ""
    read -p "Continue with this configuration? (yes/no): " confirm
    
    if [ "$confirm" != "yes" ]; then
        echo ""
        echo "Edit configuration:"
        echo "  nano .env"
        exit 0
    fi
fi

echo ""
echo "=========================================="
echo "STEP 1/2: Deploying Odoo Stack"
echo "=========================================="
echo ""

# Deploy Odoo
bash $SCRIPT_DIR/scripts/deploy-all.sh

if [ $? -ne 0 ]; then
    echo "❌ Odoo deployment failed"
    exit 1
fi

echo ""
echo "=========================================="
echo "STEP 2/2: Setting up Automated Backups"
echo "=========================================="
echo ""

bash $SCRIPT_DIR/scripts/setup-backups.sh

echo ""
echo "=========================================="
echo "🎉 ODOO INSTALLATION COMPLETE!"
echo "=========================================="
echo ""
echo "✅ Odoo 19 deployed"
echo "✅ PostgreSQL 17 running"
echo "✅ Traefik with SSL configured"
echo "✅ Automated backups enabled (daily at 2:00 AM)"
echo ""

# Show deployment status
echo "📊 Deployment Status:"
kubectl get pods -n odoo
kubectl get pods -n postgresql
kubectl get pods -n traefik

echo ""
echo "=========================================="
echo "🌐 Access Information"
echo "=========================================="
echo ""

# Get LoadBalancer IP or NodePort
EXTERNAL_IP=$(kubectl get svc traefik -n traefik -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)

if [ -z "$EXTERNAL_IP" ]; then
    # Try to get NodePort
    NODE_IP=$(hostname -I | awk '{print $1}')
    HTTP_PORT=$(kubectl get svc traefik -n traefik -o jsonpath='{.spec.ports[?(@.name=="web")].nodePort}' 2>/dev/null)
    HTTPS_PORT=$(kubectl get svc traefik -n traefik -o jsonpath='{.spec.ports[?(@.name=="websecure")].nodePort}' 2>/dev/null)
    
    echo "📍 Server IP: $NODE_IP"
    echo "🔗 HTTP Port: $HTTP_PORT"
    echo "🔗 HTTPS Port: $HTTPS_PORT"
    echo ""
    echo "⚠️  Configure your DNS:"
    echo "   Point $DOMAIN to: $NODE_IP"
    echo ""
else
    echo "📍 LoadBalancer IP: $EXTERNAL_IP"
    echo ""
    echo "⚠️  Configure your DNS:"
    echo "   Point $DOMAIN to: $EXTERNAL_IP"
    echo ""
fi

echo "🌐 Once DNS is configured, access:"
echo "   https://$DOMAIN"
echo ""

echo "=========================================="
echo "📚 Backup Commands"
echo "=========================================="
echo ""
echo "Run manual backup:"
echo "  ./scripts/backup-now.sh"
echo ""
echo "List backups:"
echo "  ./scripts/list-backups.sh"
echo ""
echo "Restore backup:"
echo "  ./scripts/restore-backup.sh <backup-file>"
echo ""

echo "=========================================="
echo "📊 Monitoring Commands"
echo "=========================================="
echo ""
echo "View Odoo logs:"
echo "  kubectl logs -n odoo -l app=odoo -f"
echo ""
echo "View PostgreSQL logs:"
echo "  kubectl logs -n postgresql -l app=postgresql -f"
echo ""
echo "View all pods:"
echo "  kubectl get pods -A"
echo ""
echo "Use visual tools:"
echo "  k9s                          # Terminal UI"
echo "  ./scripts/open-dashboard.sh  # Web UI"
echo ""

echo "=========================================="
echo "⚙️  Management Commands"
echo "=========================================="
echo ""
echo "Scale Odoo (increase replicas):"
echo "  kubectl scale deployment odoo -n odoo --replicas=3"
echo ""
echo "Restart Odoo:"
echo "  kubectl rollout restart deployment odoo -n odoo"
echo ""
echo "Update Odoo:"
echo "  ./scripts/update-odoo.sh"
echo ""

echo "📖 Full documentation: cat README.md"
echo ""
echo "🎉 Enjoy your Odoo installation!"
