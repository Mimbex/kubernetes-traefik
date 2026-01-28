#!/bin/bash
# Backup diario de PostgreSQL en Kubernetes
# Añadir al crontab: 0 3 * * * /opt/kubernetes-traefik/scripts/backup_daily.sh

BACKUP_DIR="/var/lib/odoo-storage/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
FILENAME="$BACKUP_DIR/odoo_db_$TIMESTAMP.sql.gz"
RETENTION_DAYS=7

# Encontrar pod de postgres
PG_POD=$(/snap/bin/kubectl get pod -n postgresql -l app=postgresql -o jsonpath="{.items[0].metadata.name}")

if [ -z "$PG_POD" ]; then
    echo "❌ No se encontró el pod de Postgres!"
    exit 1
fi

echo "🐘 Iniciando backup de $PG_POD a $FILENAME..."

# Ejecutar pg_dump dentro del pod y comprimir en streaming al host
/snap/bin/kubectl exec $PG_POD -n postgresql -- pg_dump -U odoo -d postgres | gzip > $FILENAME

if [ $? -eq 0 ]; then
    echo "✅ Backup completado exitosamente."
else
    echo "❌ Error al crear backup."
    rm -f $FILENAME
    exit 1
fi

# Eliminar backups antiguos
echo "🧹 Limpiando backups antiguos (> $RETENTION_DAYS dias)..."
find $BACKUP_DIR -name "odoo_db_*.sql.gz" -mtime +$RETENTION_DAYS -delete

echo "✨ Proceso finalizado."
