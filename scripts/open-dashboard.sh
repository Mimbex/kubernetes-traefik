#!/bin/bash

echo "📊 Opening Kubernetes Dashboard"
echo "================================"
echo ""

# Check if dashboard is installed
if ! kubectl get deployment kubernetes-dashboard -n kubernetes-dashboard &> /dev/null; then
    echo "❌ Dashboard not installed"
    echo ""
    read -p "Install dashboard now? (yes/no): " install
    if [ "$install" == "yes" ]; then
        ./scripts/install-dashboard.sh
    else
        echo "Run: ./scripts/install-dashboard.sh"
        exit 1
    fi
fi

echo "🔑 Generating access token..."
echo ""
TOKEN=$(kubectl -n kubernetes-dashboard create token admin-user 2>/dev/null)

if [ -z "$TOKEN" ]; then
    echo "❌ Failed to generate token"
    echo "Dashboard might not be installed correctly"
    exit 1
fi

echo "✅ Token generated!"
echo ""
echo "=========================================="
echo "📋 Your Dashboard Access Token:"
echo "=========================================="
echo ""
echo "$TOKEN"
echo ""
echo "=========================================="
echo ""
echo "⚠️  COPY THE TOKEN ABOVE!"
echo ""
echo "🚀 Starting dashboard proxy..."
echo ""
echo "Dashboard will be available at:"
echo "http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"
echo ""
echo "📝 Steps:"
echo "1. Copy the token above (already in your clipboard if using terminal)"
echo "2. Open the URL in your browser"
echo "3. Select 'Token' login method"
echo "4. Paste the token"
echo "5. Click 'Sign In'"
echo ""
echo "Press Ctrl+C to stop the proxy when done"
echo ""
echo "Starting proxy in 5 seconds..."
sleep 5

# Copy token to clipboard if possible
if command -v xclip &> /dev/null; then
    echo "$TOKEN" | xclip -selection clipboard
    echo "✅ Token copied to clipboard!"
elif command -v pbcopy &> /dev/null; then
    echo "$TOKEN" | pbcopy
    echo "✅ Token copied to clipboard!"
fi

# Start proxy
kubectl proxy
