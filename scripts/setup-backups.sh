#!/bin/bash

echo "📦 Setting up Odoo Backup System"
echo "================================="

# Create backup directory on host
echo "Creating backup directory..."
sudo mkdir -p /opt/backups
sudo chmod 777 /opt/backups

# Deploy backup namespace and resources
echo "Creating backup namespace..."
kubectl apply -f backups/00-namespace.yaml

echo "Creating backup storage..."
kubectl apply -f backups/00-pv.yaml
kubectl apply -f backups/01-pvc.yaml

echo "Creating backup scripts..."
kubectl apply -f backups/02-backup-script.yaml
kubectl apply -f backups/05-restore-script.yaml

echo "Creating backup CronJob..."
envsubst < backups/03-cronjob.yaml | kubectl apply -f -

echo ""
echo "✅ Backup system configured!"
echo ""
echo "📋 Backup Schedule:"
echo "   Daily at 2:00 AM UTC"
echo "   Retention: 7 days"
echo ""
echo "📚 Useful commands:"
echo "   ./scripts/backup-now.sh          - Run manual backup"
echo "   ./scripts/list-backups.sh        - List all backups"
echo "   ./scripts/restore-backup.sh      - Restore from backup"
echo ""
