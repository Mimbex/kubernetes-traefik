#!/bin/bash

echo "🔄 Reloading Odoo Configuration..."
echo ""

# Aplicar ConfigMap actualizado
echo "1️⃣ Applying updated ConfigMap..."
envsubst < odoo/01-configmap.yaml | kubectl apply -f -

echo ""
echo "2️⃣ Restarting Odoo deployment to load new config..."
kubectl rollout restart deployment/odoo -n odoo

echo ""
echo "⏳ Waiting for Odoo to restart..."
kubectl rollout status deployment/odoo -n odoo

echo ""
echo "✅ Configuration reloaded!"
echo ""
echo "📊 Current status:"
kubectl get pods -n odoo
echo ""
echo "📝 View logs: kubectl logs -n odoo deployment/odoo -f"
