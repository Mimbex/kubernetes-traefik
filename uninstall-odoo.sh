#!/bin/bash

echo "🗑️  Odoo Stack Uninstallation"
echo "============================="
echo ""
echo "⚠️  WARNING: This will DELETE all data!"
echo ""
echo "This will remove:"
echo "  ❌ All Odoo databases"
echo "  ❌ All PostgreSQL data"
echo "  ❌ All Traefik configurations"
echo "  ❌ All backups"
echo "  ❌ All Kubernetes resources"
echo ""

read -p "Are you sure you want to continue? (type 'yes' to confirm): " confirm

if [ "$confirm" != "yes" ]; then
    echo "❌ Uninstallation cancelled"
    exit 0
fi

echo ""
echo "🗑️  Starting uninstallation..."
echo ""

# Delete Kubernetes namespaces
echo "1️⃣ Deleting Kubernetes namespaces..."
kubectl delete namespace odoo --ignore-not-found=true
kubectl delete namespace postgresql --ignore-not-found=true
kubectl delete namespace traefik --ignore-not-found=true
kubectl delete namespace backups --ignore-not-found=true

# Delete PersistentVolumes
echo ""
echo "2️⃣ Deleting PersistentVolumes..."
kubectl delete pv --all --ignore-not-found=true

# Clean host directories
echo ""
echo "3️⃣ Cleaning host directories..."
echo "   Removing /opt/odoo-data..."
sudo rm -rf /opt/odoo-data/*

echo "   Removing /opt/odoo-extra-addons..."
sudo rm -rf /opt/odoo-extra-addons/*

echo "   Removing /opt/postgresql-data..."
sudo rm -rf /opt/postgresql-data/*

echo "   Removing /opt/traefik-letsencrypt..."
sudo rm -rf /opt/traefik-letsencrypt/*

echo "   Removing /opt/backups..."
sudo rm -rf /opt/backups/*

# Verify cleanup
echo ""
echo "4️⃣ Verifying cleanup..."
REMAINING_PODS=$(kubectl get pods -n odoo,postgresql,traefik,backups 2>/dev/null | wc -l)
REMAINING_PVS=$(kubectl get pv 2>/dev/null | grep -v NAME | wc -l)

echo ""
echo "=========================================="
echo "✅ UNINSTALLATION COMPLETE!"
echo "=========================================="
echo ""
echo "📊 Cleanup Summary:"
echo "   Namespaces deleted: odoo, postgresql, traefik, backups"
echo "   PersistentVolumes deleted: All"
echo "   Host data cleaned: All"
echo ""

if [ "$REMAINING_PODS" -gt 0 ] || [ "$REMAINING_PVS" -gt 0 ]; then
    echo "⚠️  Some resources may still be terminating..."
    echo "   Run 'kubectl get all -A' to check status"
else
    echo "✅ All resources successfully removed"
fi

echo ""
echo "🚀 To reinstall Odoo:"
echo "   1. Edit .env with your configuration"
echo "   2. Run: ./install-odoo.sh"
echo ""
