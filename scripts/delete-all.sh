#!/bin/bash

echo "🗑️  Deleting all resources..."
echo "=============================="

read -p "Are you sure you want to delete everything? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "❌ Cancelled"
    exit 0
fi

echo "Deleting Odoo..."
kubectl delete -f odoo/04-ingress.yaml
kubectl delete -f odoo/03-service.yaml
kubectl delete -f odoo/02-deployment.yaml
kubectl delete -f odoo/01-configmap.yaml
kubectl delete namespace odoo

echo "Deleting PostgreSQL..."
kubectl delete -f postgresql/02-statefulset.yaml
kubectl delete -f postgresql/01-secret.yaml
kubectl delete namespace postgresql

echo "Deleting Traefik..."
kubectl delete -f traefik/03-service.yaml
kubectl delete -f traefik/02-deployment.yaml
kubectl delete -f traefik/01-rbac.yaml
kubectl delete namespace traefik

echo "✅ All resources deleted"
