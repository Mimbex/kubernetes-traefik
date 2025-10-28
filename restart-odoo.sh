#!/bin/bash

echo "🔄 Restarting Odoo..."
echo ""

# Check if ConfigMap was modified
if git diff --quiet HEAD -- odoo/01-configmap.yaml 2>/dev/null; then
    CONFIG_CHANGED=false
else
    CONFIG_CHANGED=true
fi

# Check if there are uncommitted changes to ConfigMap
if [ -f "odoo/01-configmap.yaml" ]; then
    if git status --porcelain odoo/01-configmap.yaml 2>/dev/null | grep -q "^.M"; then
        CONFIG_CHANGED=true
    fi
fi

if [ "$CONFIG_CHANGED" = true ]; then
    echo "⚙️  ConfigMap changes detected, applying full restart..."
    echo ""
    
    # Apply ConfigMap
    echo "1️⃣ Applying updated ConfigMap..."
    envsubst < odoo/01-configmap.yaml | kubectl apply -f -
    
    echo ""
    echo "2️⃣ Restarting Odoo deployment..."
    kubectl rollout restart deployment/odoo -n odoo
    
    echo ""
    echo "⏳ Waiting for Odoo to restart..."
    kubectl rollout status deployment/odoo -n odoo --timeout=120s
    
else
    echo "⚡ Fast restart (no config changes)..."
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
fi

echo ""
echo "✅ Odoo restarted!"
echo ""
echo "📊 Current status:"
kubectl get pods -n odoo
echo ""
echo "📝 View logs: kubectl logs -n odoo deployment/odoo -f"
