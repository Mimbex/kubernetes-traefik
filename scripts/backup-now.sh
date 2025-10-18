#!/bin/bash

echo "🔄 Running manual backup..."
echo "==========================="

# Delete previous manual backup job if exists
kubectl delete job odoo-manual-backup -n backups 2>/dev/null || true

# Create new backup job
kubectl apply -f backups/04-manual-backup-job.yaml

# Wait for job to complete
echo "⏳ Waiting for backup to complete..."
kubectl wait --for=condition=complete --timeout=300s job/odoo-manual-backup -n backups

# Show logs
echo ""
echo "📋 Backup logs:"
kubectl logs -n backups job/odoo-manual-backup

echo ""
echo "✅ Manual backup completed!"
