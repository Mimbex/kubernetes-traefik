#!/bin/bash

echo "🌐 Exposing Kubernetes Dashboard to External IP"
echo "================================================"
echo ""

# Change dashboard service to NodePort
kubectl patch svc kubernetes-dashboard -n kubernetes-dashboard -p '{"spec":{"type":"NodePort"}}'

# Get the NodePort
NODEPORT=$(kubectl get svc kubernetes-dashboard -n kubernetes-dashboard -o jsonpath='{.spec.ports[0].nodePort}')

# Get server IP
SERVER_IP=$(hostname -I | awk '{print $1}')

echo "✅ Dashboard exposed!"
echo ""
echo "=========================================="
echo "📊 Access Kubernetes Dashboard"
echo "=========================================="
echo ""
echo "🌐 Dashboard URL:"
echo "   https://$SERVER_IP:$NODEPORT"
echo ""
echo "⚠️  Your browser will show a security warning (self-signed certificate)"
echo "   Click 'Advanced' -> 'Proceed to site'"
echo ""
echo "🔑 Get your access token:"
echo "   kubectl -n kubernetes-dashboard create token admin-user"
echo ""
echo "📋 Steps:"
echo "1. Open: https://$SERVER_IP:$NODEPORT"
echo "2. Accept security warning"
echo "3. Select 'Token' login"
echo "4. Run: kubectl -n kubernetes-dashboard create token admin-user"
echo "5. Copy and paste the token"
echo "6. Click 'Sign In'"
echo ""
