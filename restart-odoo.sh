#!/bin/bash

echo "🔄 Restarting Odoo (fast mode)..."
echo ""

# Get pod name
POD_NAME=$(kubectl get pod -n odoo -l app=odoo -o jsonpath='{.items[0].metadata.name}')

if [ -z "$POD_NAME" ]; then
    echo "❌ No Odoo pod found"
    exit 1
fi

echo "📦 Pod: $POD_NAME"
echo ""

# Kill the Odoo process inside the container (it will restart automatically)
echo "⚡ Killing Odoo process (will restart automatically)..."
kubectl exec -n odoo $POD_NAME -- pkill -f odoo-bin 2>/dev/null || kubectl exec -n odoo $POD_NAME -- pkill -f openerp-server 2>/dev/null

echo ""
echo "⏳ Waiting 5 seconds for Odoo to restart..."
sleep 5

echo ""
echo "✅ Odoo restarted!"
echo ""
echo "📊 Current status:"
kubectl get pods -n odoo
echo ""
echo "📝 View logs: kubectl logs -n odoo $POD_NAME -f"
