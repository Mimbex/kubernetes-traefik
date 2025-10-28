#!/bin/bash

echo "🔧 CNI Plugins Fix Script"
echo "========================="
echo ""

# Check if required CNI plugins exist
REQUIRED_PLUGINS="loopback bridge host-local portmap"
MISSING_PLUGINS=""

for plugin in $REQUIRED_PLUGINS; do
    if [ ! -f "/opt/cni/bin/$plugin" ]; then
        MISSING_PLUGINS="$MISSING_PLUGINS $plugin"
    fi
done

if [ ! -z "$MISSING_PLUGINS" ]; then
    echo "⚠️  Missing CNI plugins:$MISSING_PLUGINS"
    echo "📦 Installing complete CNI plugin set..."
    
    sudo mkdir -p /opt/cni/bin
    CNI_VERSION="v1.3.0"
    
    cd /tmp
    wget -q https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-linux-amd64-${CNI_VERSION}.tgz -O cni-plugins.tgz
    
    if [ $? -ne 0 ]; then
        echo "❌ Failed to download CNI plugins"
        exit 1
    fi
    
    # Extract without overwriting flannel
    sudo tar -xzf cni-plugins.tgz -C /opt/cni/bin/ --skip-old-files 2>/dev/null || sudo tar -xzf cni-plugins.tgz -C /opt/cni/bin/
    rm cni-plugins.tgz
    
    echo "✅ CNI plugins installed"
    echo ""
    
    # Restart containerd
    echo "🔄 Restarting containerd..."
    sudo systemctl restart containerd
    
    echo "✅ containerd restarted"
    echo ""
else
    echo "✅ All required CNI plugins present"
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
