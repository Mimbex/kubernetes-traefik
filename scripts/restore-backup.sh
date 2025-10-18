#!/bin/bash

if [ -z "$1" ]; then
    echo "❌ Error: No backup file specified"
    echo ""
    echo "Usage: ./scripts/restore-backup.sh <backup-file.tar.gz>"
    echo ""
    echo "Available backups:"
    ./scripts/list-backups.sh
    exit 1
fi

BACKUP_FILE="$1"

echo "⚠️  WARNING: This will restore the database from backup!"
echo "   Backup file: $BACKUP_FILE"
echo ""
read -p "Are you sure you want to continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "❌ Restore cancelled"
    exit 0
fi

echo ""
echo "🔄 Starting restore process..."
echo "=============================="

# Create restore job
cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: odoo-restore
  namespace: backups
spec:
  template:
    spec:
      restartPolicy: Never
      containers:
        - name: restore
          image: postgres:17
          env:
            - name: POSTGRES_PASSWORD
              value: "odoo"
          command:
            - /bin/bash
            - /scripts/restore.sh
            - "${BACKUP_FILE}"
          volumeMounts:
            - name: backup-storage
              mountPath: /backups
            - name: restore-script
              mountPath: /scripts
      volumes:
        - name: backup-storage
          persistentVolumeClaim:
            claimName: backup-storage
        - name: restore-script
          configMap:
            name: restore-script
            defaultMode: 0755
EOF

# Wait for job to complete
echo "⏳ Waiting for restore to complete..."
kubectl wait --for=condition=complete --timeout=600s job/odoo-restore -n backups

# Show logs
echo ""
echo "📋 Restore logs:"
kubectl logs -n backups job/odoo-restore

# Cleanup
kubectl delete job odoo-restore -n backups

echo ""
echo "✅ Restore completed!"
echo "🔄 Restart Odoo pods to apply changes:"
echo "   kubectl rollout restart deployment odoo -n odoo"
