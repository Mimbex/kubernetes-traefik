#!/bin/bash

echo "🚀 Deploying Kubernetes + Traefik + Odoo + PostgreSQL"
echo "======================================================"

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
echo "   Odoo Version: $ODOO_VERSION"
echo "   Odoo Domain: $ODOO_DOMAIN"
echo "   Let's Encrypt Email: $LETSENCRYPT_EMAIL"
echo ""

# Check if we need to build custom Odoo image
MAJOR_VERSION=$(echo $ODOO_VERSION | cut -d'.' -f1)
MINOR_VERSION=$(echo $ODOO_VERSION | cut -d'.' -f2)

# If minor version exists and is not 0, we need to build from source
if [ ! -z "$MINOR_VERSION" ] && [ "$MINOR_VERSION" != "0" ]; then
    echo "🔨 Custom Odoo version detected: $ODOO_VERSION"
    echo "   Building Docker image from source (saas-$ODOO_VERSION branch)..."
    echo ""
    
    # Check if Docker is available
    if ! command -v docker &> /dev/null; then
        echo "❌ Docker not found! Cannot build custom image."
        echo "   Install Docker or use a standard version (17.0, 16.0, etc.)"
        exit 1
    fi
    
    # Build custom image
    echo "📦 Building odoo:$ODOO_VERSION (this may take 5-10 minutes)..."
    cd odoo
    docker build -t odoo:$ODOO_VERSION --build-arg ODOO_VERSION=$ODOO_VERSION -f Dockerfile.custom . || {
        echo "❌ Failed to build Docker image"
        exit 1
    }
    cd ..
    echo "✅ Custom Odoo image built successfully!"
    echo ""
else
    echo "📦 Using official Odoo image from Docker Hub: odoo:$ODOO_VERSION"
    echo ""
fi

# Clean up old PersistentVolumes if they exist in Released state
echo "🧹 Cleaning up old resources..."
kubectl get pv 2>/dev/null | grep Released | awk '{print $1}' | xargs -r kubectl delete pv 2>/dev/null || true

# Create host directories with correct permissions
echo "📁 Creating host directories..."
sudo mkdir -p /opt/odoo-data /opt/odoo-extra-addons /opt/postgresql-data /opt/traefik-letsencrypt /opt/backups
sudo chown -R 101:101 /opt/odoo-data /opt/odoo-extra-addons
sudo chmod -R 777 /opt/odoo-data /opt/odoo-extra-addons /opt/backups
sudo chmod -R 755 /opt/postgresql-data /opt/traefik-letsencrypt

# Create PersistentVolumes
echo "📦 Creating storage..."
kubectl apply -f postgresql/01-storageclass.yaml 2>/dev/null || true
kubectl apply -f traefik/01-pv.yaml 2>/dev/null || true
kubectl apply -f postgresql/00-pv.yaml 2>/dev/null || true
kubectl apply -f odoo/00-pv.yaml 2>/dev/null || true
kubectl apply -f backups/00-pv.yaml 2>/dev/null || true

# Deploy Traefik
echo "📦 Deploying Traefik..."
kubectl apply -f traefik/00-namespace.yaml

# Install Traefik CRDs
echo "📦 Installing Traefik CRDs..."
kubectl apply -f https://raw.githubusercontent.com/traefik/traefik/v2.10/docs/content/reference/dynamic-configuration/kubernetes-crd-definition-v1.yml

kubectl apply -f traefik/01-rbac.yaml
envsubst < traefik/02-deployment.yaml | kubectl apply -f -
kubectl apply -f traefik/03-service.yaml
kubectl apply -f traefik/04-ingressclass.yaml

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
envsubst < odoo/01-configmap.yaml | kubectl apply -f -
envsubst < odoo/02-deployment.yaml | kubectl apply -f -
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
