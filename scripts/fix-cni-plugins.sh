#!/bin/bash

echo "🔧 CNI Plugins Fix Script"
echo "========================="
echo ""

# Check if CNI plugins exist
if [ ! -d "/opt/cni/bin" ] || [ -z "$(ls -A /opt/cni/bin)" ]; then
    echo "⚠️  CNI plugins not found or empty"
    echo "📦 Installing CNI plugins..."
    
    sudo mkdir -p /opt/cni/bin
    CNI_VERSION="v1.3.0"
    
    cd /tmp
    wget -q https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-linux-amd64-${CNI_VERSION}.tgz -O cni-plugins.tgz
    
    if [ $? -ne 0 ]; then
        echo "❌ Failed to download CNI plugins"
        exit 1
    fi
    
    sudo tar -xzf cni-plugins.tgz -C /opt/cni/bin/
    rm cni-plugins.tgz
    
    echo "✅ CNI plugins installed"
    echo ""
    
    # Restart containerd
    echo "🔄 Restarting containerd..."
    sudo systemctl restart containerd
    
    echo "✅ containerd restarted"
    echo ""
else
    echo "✅ CNI plugins already installed"
    ls -la /opt/cni/bin/ | head -5
    echo ""
fi

# Check for stuck pods
echo "🔍 Checking for stuck pods..."
STUCK_PODS=$(kubectl get pods -A --field-selector=status.phase=Pending -o jsonpath='{range .items[*]}{.metadata.namespace}{" "}{.metadata.name}{"\n"}{end}')

if [ ! -z "$STUCK_PODS" ]; then
    echo "⚠️  Found stuck pods:"
    echo "$STUCK_PODS"
    echo ""
    echo "🔄 Deleting stuck pods to force recreation..."
    
    while IFS= read -r line; do
        if [ ! -z "$line" ]; then
            NAMESPACE=$(echo $line | awk '{print $1}')
            POD=$(echo $line | awk '{print $2}')
            echo "   Deleting $POD in namespace $NAMESPACE..."
            kubectl delete pod $POD -n $NAMESPACE --grace-period=0 --force 2>/dev/null
        fi
    done <<< "$STUCK_PODS"
    
    echo ""
    echo "✅ Stuck pods deleted"
    echo ""
    echo "⏳ Waiting for pods to recreate (30 seconds)..."
    sleep 30
else
    echo "✅ No stuck pods found"
    echo ""
fi

# Show current status
echo "=========================================="
echo "📊 Current Status"
echo "=========================================="
echo ""
kubectl get pods -A
echo ""
echo "✅ Fix complete!"
