#!/bin/bash

# Config
SERVER_IP="161.132.45.204"
USER="root"

echo "🔄 Restarting Odoo Service on $SERVER_IP..."
ssh -o StrictHostKeyChecking=no $USER@$SERVER_IP "kubectl rollout restart deployment odoo -n odoo"

echo "⏳ Waiting for Odoo to be ready..."
ssh -o StrictHostKeyChecking=no $USER@$SERVER_IP "kubectl rollout status deployment/odoo -n odoo"

echo "✅ Odoo Restarted Successfully!"
