#!/bin/bash

echo "🔄 Restarting Odoo..."
echo ""

# Force fast restart by default
FORCE_FAST="${1:-}"

if [ "$FORCE_FAST" = "--full" ]; then
    echo "⚙️  Full restart requested..."
    echo ""
    
    # Apply ConfigMap
    echo "1️⃣ Applying updated ConfigMap..."
    envsubst < odoo/01-configmap.yaml | kubectl apply -f -
    
    echo ""
    echo "2️⃣ Deleting all pods to force recreation..."
    kubectl delete pod -n odoo -l app=odoo --force --grace-period=0
    
    echo ""
    echo "⏳ Waiting for new pod to be ready..."
    kubectl wait --for=condition=ready pod -l app=odoo -n odoo --timeout=120s
    
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
