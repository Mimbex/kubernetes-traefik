#!/bin/bash

echo "🔄 Restarting Odoo..."
kubectl rollout restart deployment/odoo -n odoo

echo ""
echo "⏳ Waiting for Odoo to restart..."
kubectl rollout status deployment/odoo -n odoo

echo ""
echo "✅ Odoo restarted successfully!"
echo ""
echo "📊 Current status:"
kubectl get pods -n odoo
echo ""
echo "📝 View logs with: kubectl logs -n odoo deployment/odoo -f"
