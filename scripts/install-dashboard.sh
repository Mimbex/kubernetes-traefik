#!/bin/bash

echo "📊 Installing Kubernetes Dashboard"
echo "==================================="
echo ""

# Install Kubernetes Dashboard
echo "1️⃣ Deploying Kubernetes Dashboard..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

echo ""
echo "2️⃣ Creating admin user..."

# Create admin user
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF

echo ""
echo "3️⃣ Waiting for dashboard to be ready..."
kubectl wait --for=condition=available --timeout=120s deployment/kubernetes-dashboard -n kubernetes-dashboard

echo ""
echo "✅ Dashboard installed successfully!"
echo ""
echo "=========================================="
echo "📊 Kubernetes Dashboard Access"
echo "=========================================="
echo ""
echo "🔑 Get your access token:"
echo ""
echo "kubectl -n kubernetes-dashboard create token admin-user"
echo ""
echo "🌐 Start dashboard proxy:"
echo ""
echo "kubectl proxy"
echo ""
echo "🔗 Then open in your browser:"
echo ""
echo "http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"
echo ""
echo "📋 Steps to access:"
echo "1. Run: kubectl -n kubernetes-dashboard create token admin-user"
echo "2. Copy the token"
echo "3. Run: kubectl proxy"
echo "4. Open the URL above in your browser"
echo "5. Paste the token to login"
echo ""
echo "💡 Or use this shortcut script:"
echo "   ./scripts/open-dashboard.sh"
echo ""
