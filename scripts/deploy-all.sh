#!/bin/bash

echo "🚀 Deploying Kubernetes + Traefik + Odoo 19 + PostgreSQL"
echo "=========================================================="

# Load environment variables
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found!"
    echo "📝 Copy .env.example to .env and configure your domains"
    exit 1
fi

set -a
source .env
set +a

echo "📋 Configuration:"
echo "   Odoo Domain: $ODOO_DOMAIN"
echo "   Let's Encrypt Email: $LETSENCRYPT_EMAIL"
echo ""

# Create PersistentVolumes
echo "📦 Creating storage..."
kubectl apply -f postgresql/01-storageclass.yaml 2>/dev/null || true
kubectl apply -f traefik/01-pv.yaml 2>/dev/null || true
kubectl apply -f postgresql/00-pv.yaml 2>/dev/null || true
kubectl apply -f odoo/00-pv.yaml 2>/dev/null || true

# Deploy Traefik
echo "📦 Deploying Traefik..."
kubectl apply -f traefik/00-namespace.yaml

# Install Traefik CRDs
echo "📦 Installing Traefik CRDs..."
kubectl apply -f https://raw.githubusercontent.com/traefik/traefik/v2.10/docs/content/reference/dynamic-configuration/kubernetes-crd-definition-v1.yml

kubectl apply -f traefik/01-rbac.yaml
envsubst < traefik/02-deployment.yaml | kubectl apply -f -
kubectl apply -f traefik/03-service.yaml

# Wait for Traefik
echo "⏳ Waiting for Traefik to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/traefik -n traefik

# Deploy PostgreSQL
echo "📦 Deploying PostgreSQL..."
kubectl apply -f postgresql/00-namespace.yaml
kubectl apply -f postgresql/01-secret.yaml
kubectl apply -f postgresql/02-statefulset.yaml

# Wait for PostgreSQL
echo "⏳ Waiting for PostgreSQL to be ready..."
kubectl wait --for=condition=ready --timeout=300s pod -l app=postgresql -n postgresql

# Deploy Odoo
echo "📦 Deploying Odoo..."
kubectl apply -f odoo/00-namespace.yaml
kubectl apply -f odoo/01-configmap.yaml
kubectl apply -f odoo/02-deployment.yaml
kubectl apply -f odoo/03-service.yaml
envsubst < odoo/04-ingress.yaml | kubectl apply -f -

# Wait for Odoo
echo "⏳ Waiting for Odoo to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/odoo -n odoo

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📊 Status:"
kubectl get pods -n traefik
kubectl get pods -n postgresql
kubectl get pods -n odoo
echo ""
echo "🌐 Get LoadBalancer IP:"
kubectl get svc traefik -n traefik
echo ""
echo "📝 Point your domain to the EXTERNAL-IP above"
echo "🔗 Access Odoo at: https://$ODOO_DOMAIN"
