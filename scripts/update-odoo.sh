#!/bin/bash

echo "🔄 Updating Odoo deployment..."
echo "=============================="

kubectl apply -f odoo/02-deployment.yaml
kubectl rollout status deployment/odoo -n odoo

echo "✅ Odoo updated successfully"
