# Backup & Restore Guide

**Complete** automated backup system for Odoo including:
- ✅ PostgreSQL database
- ✅ Odoo filestore (attachments, images, documents)
- ✅ Odoo sessions
- ✅ Backup manifest with metadata

## 🚀 Quick Start

### Setup Backups

```bash
./scripts/setup-backups.sh
```

This will:
- Create backup namespace
- Configure 50GB storage for backups
- Set up daily automated backups at 2:00 AM UTC
- Keep backups for 7 days

## 📦 Backup Operations

### Manual Backup

Run a backup immediately:

```bash
./scripts/backup-now.sh
```

### List Backups

View all available backups:

```bash
./scripts/list-backups.sh
```

### Restore from Backup

Restore database from a specific backup:

```bash
./scripts/restore-backup.sh 20251017_020000.tar.gz
```

⚠️ **Warning:** This will overwrite your current database!

## ⚙️ Configuration

### Backup Schedule

Edit `backups/03-cronjob.yaml` to change the schedule:

```yaml
spec:
  # Run daily at 2:00 AM UTC
  schedule: "0 2 * * *"
```

**Common schedules:**
- Every 6 hours: `"0 */6 * * *"`
- Every 12 hours: `"0 */12 * * *"`
- Daily at 3 AM: `"0 3 * * *"`
- Weekly on Sunday: `"0 2 * * 0"`

### Retention Period

Edit `backups/02-backup-script.yaml`:

```bash
RETENTION_DAYS=7  # Change to your desired retention
```

### Storage Size

Edit `backups/01-pvc.yaml`:

```yaml
resources:
  requests:
    storage: 50Gi  # Adjust based on your needs
```

## 📊 Monitoring

### Check Backup Jobs

```bash
# View CronJob status
kubectl get cronjob -n backups

# View recent backup jobs
kubectl get jobs -n backups

# View backup logs
kubectl logs -n backups -l job-name=odoo-backup
```

### Check Storage Usage

```bash
kubectl exec -n backups <backup-pod> -- df -h /backups
```

## 🔄 Backup Process

The backup system performs a **complete backup**:

1. **PostgreSQL Database** - Full dump using `pg_dump`
2. **Odoo Filestore** - All uploaded files, attachments, images
3. **Odoo Sessions** - Active user sessions (optional)
4. **Manifest** - Backup metadata and information
5. **Compression** - Everything compressed into single `.tar.gz`
6. **Cleanup** - Old backups removed based on retention policy

## 📁 Backup Contents

Each backup (`YYYYMMDD_HHMMSS_complete.tar.gz`) includes:

```
20251017_020000_complete.tar.gz
├── database.dump          # PostgreSQL database
├── filestore.tar.gz       # Odoo filestore (attachments, images)
├── sessions.tar.gz        # User sessions (optional)
└── manifest.txt           # Backup metadata
```

**Manifest example:**
```
Backup Date: Thu Oct 17 02:00:00 UTC 2025
Timestamp: 20251017_020000
Database: postgres
Database Size: 250M
Filestore Size: 1.2G
Odoo Version: 19.0
PostgreSQL Version: 17
```

## 🔐 Security

### Backup Encryption (Optional)

To encrypt backups, modify `backups/02-backup-script.yaml`:

```bash
# Add after compression
gpg --symmetric --cipher-algo AES256 ${TIMESTAMP}.tar.gz
rm ${TIMESTAMP}.tar.gz
```

### Access Control

Backups are stored in a separate namespace with restricted access:

```bash
# Only allow specific users to access backups
kubectl create rolebinding backup-admin \
  --clusterrole=admin \
  --user=backup-admin@example.com \
  -n backups
```

## 🌐 Remote Backup Storage

### Upload to S3 (AWS)

Add to backup script:

```bash
# Install AWS CLI in backup container
apt-get update && apt-get install -y awscli

# Upload to S3
aws s3 cp ${TIMESTAMP}.tar.gz s3://your-bucket/odoo-backups/
```

### Upload to Google Cloud Storage

```bash
# Install gsutil
apt-get update && apt-get install -y google-cloud-sdk

# Upload to GCS
gsutil cp ${TIMESTAMP}.tar.gz gs://your-bucket/odoo-backups/
```

## 🔧 Advanced Operations

### Manual Database Backup

```bash
kubectl run pg-backup --rm -i --tty --image=postgres:17 -n backups \
  --env="PGPASSWORD=odoo" -- \
  pg_dump -h postgresql.postgresql.svc.cluster.local \
  -U odoo -d postgres -F c -f /tmp/manual-backup.dump
```

### Restore Specific Tables

```bash
# Restore only specific tables
pg_restore -h postgresql.postgresql.svc.cluster.local \
  -U odoo -d postgres \
  -t table_name \
  backup.dump
```

### Copy Backup to Local Machine

```bash
# Get backup pod
POD=$(kubectl get pod -n backups -l job-name -o jsonpath='{.items[0].metadata.name}')

# Copy backup file
kubectl cp backups/$POD:/backups/20251017_020000.tar.gz ./local-backup.tar.gz
```

## 📋 Troubleshooting

### Backup Job Failed

```bash
# Check job status
kubectl describe job odoo-backup -n backups

# View logs
kubectl logs -n backups -l job-name=odoo-backup --tail=100
```

### Storage Full

```bash
# Check storage usage
kubectl exec -n backups <pod> -- du -sh /backups/*

# Manually clean old backups
kubectl exec -n backups <pod> -- rm /backups/old-backup.tar.gz
```

### Restore Failed

```bash
# Check PostgreSQL connection
kubectl exec -n backups <pod> -- \
  psql -h postgresql.postgresql.svc.cluster.local -U odoo -d postgres -c "SELECT version();"

# Verify backup file integrity
kubectl exec -n backups <pod> -- tar -tzf /backups/backup.tar.gz
```

## 📚 Best Practices

1. **Test restores regularly** - Verify backups work
2. **Monitor backup jobs** - Set up alerts for failures
3. **Store backups offsite** - Use S3, GCS, or similar
4. **Encrypt sensitive data** - Use GPG or similar
5. **Document recovery procedures** - Keep runbooks updated
6. **Verify backup integrity** - Check file sizes and contents
7. **Maintain multiple retention periods** - Daily, weekly, monthly

## 🔗 Related Documentation

- [README.md](README.md) - Main documentation
- [CONFIGURATION.md](CONFIGURATION.md) - Configuration guide
- [QUICKSTART.md](QUICKSTART.md) - Quick start guide

---

**Automated Backup System for Odoo**
© 2025 Dustin Mimbela
