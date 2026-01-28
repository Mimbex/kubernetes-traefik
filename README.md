# 🚀 Kubernetes + Traefik + Odoo (16-19)

**Production-ready Kubernetes deployment with automatic SSL, PostgreSQL, and Odoo.**

Deploy a complete Odoo ERP system (versions 16.0, 17.0, 18.0, or 19.0) in ~15 minutes with one command.

---

## ✨ What You Get

- ✅ **Kubernetes cluster** (production-ready)
- ✅ **Odoo** (versions 16.0, 17.0, 18.0, or 19.0 - your choice!)
- ✅ **PostgreSQL** (version 14, 15, 16, or 17 - configurable)
- ✅ **Traefik** (automatic SSL with Let's Encrypt)
- ✅ **Automated daily backups** (7-day retention)
- ✅ **Visual management tools** (k9s + Kubernetes Dashboard)

---

## 🎯 Quick Install (Recommended)

### Prerequisites
- **Linux server** (Ubuntu/Debian/CentOS/RHEL) or **macOS** with Docker Desktop
- **Root access** (for installation only)
- **Domain name** pointing to your server (for SSL)

### One-Command Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/kubernetes-traefik.git
cd kubernetes-traefik

# Make scripts executable
chmod +x *.sh

# Run complete installation
sudo ./install-everything.sh
```

**That's it!** ⏱️ Wait 10-15 minutes.

The script will:
1. Install Kubernetes
2. Initialize the cluster
3. Ask for your domain and email
4. Deploy Odoo + PostgreSQL + Traefik
5. Configure automated backups
6. Install visual management tools

### 🔄 Want a Different Odoo Version?

By default, this installs **Odoo 19.0** (latest). To use a different version:

**Before installation**, edit `.env`:
```env
ODOO_VERSION=18.0      # Options: 19.0, 18.0, 17.0, 16.0
POSTGRES_VERSION=16    # Options: 17, 16, 15, 14
```

**After installation**, see [Change Odoo or PostgreSQL Version](#change-odoo-or-postgresql-version) section below.

---

## 📋 Manual Installation (Step by Step)

If you prefer to understand each step or already have Kubernetes installed:

### Step 1: Install Kubernetes

**On Linux (Ubuntu/Debian/CentOS/RHEL):**
```bash
chmod +x install-kubernetes.sh
sudo ./install-kubernetes.sh
```

**On macOS:**
```bash
# Install via Homebrew
brew install kubectl minikube

# Or enable Kubernetes in Docker Desktop Settings
```

**Verify installation:**
```bash
kubectl version --client
```

### Step 2: Initialize Kubernetes Cluster

```bash
chmod +x setup-cluster.sh
sudo ./setup-cluster.sh
```

**Verify cluster is running:**
```bash
kubectl cluster-info
kubectl get nodes
```

### Step 3: Configure Environment

```bash
# Copy configuration template
cp .env.example .env

# Edit configuration
nano .env
```

**Required changes:**
```env
ODOO_DOMAIN=odoo.yourdomain.com          # Your domain
LETSENCRYPT_EMAIL=your-email@example.com # Your email for SSL
POSTGRES_PASSWORD=change_this_password   # Secure password
ODOO_ADMIN_PASSWD=change_this_too        # Odoo master password
```

### Step 4: Deploy Odoo Stack

```bash
./scripts/deploy-all.sh
```

This deploys:
- Traefik (ingress controller with SSL)
- PostgreSQL 17 (database)
- Odoo 19 (ERP system)

**Wait for pods to be ready:**
```bash
kubectl get pods --all-namespaces
```

All pods should show `STATUS: Running`.

### Step 5: Setup Automated Backups (Optional but Recommended)

```bash
./scripts/setup-backups.sh
```

This configures:
- Daily backups at 2:00 AM UTC
- 7-day retention policy
- 50GB backup storage
- Complete backups (database + filestore)

### Step 6: Configure DNS

**Get your LoadBalancer IP:**
```bash
kubectl get svc traefik -n traefik
```

**Point your domain to the EXTERNAL-IP:**
```
A Record: odoo.yourdomain.com → EXTERNAL-IP
```

### Step 7: Access Odoo

Wait 2-3 minutes for SSL certificate generation, then access:
```
https://odoo.yourdomain.com
```

**Default credentials:**
- Database: `postgres`
- Email: `admin`
- Password: (set during Odoo initialization)

---

## 🛠️ Common Operations

### View Logs

```bash
# Odoo logs
kubectl logs -n odoo -l app=odoo -f

# PostgreSQL logs
kubectl logs -n postgresql -l app=postgresql -f

# Traefik logs
kubectl logs -n traefik -l app=traefik -f
```

### Scale Odoo

```bash
# Scale to 3 replicas
kubectl scale deployment odoo -n odoo --replicas=3

# Verify
kubectl get pods -n odoo
```

### Restart Odoo

```bash
./restart-odoo.sh
```

### Manual Backup

```bash
./scripts/backup-now.sh
```

### List Backups

```bash
./scripts/list-backups.sh
```

### Restore from Backup

```bash
./scripts/restore-backup.sh 20251017_020000.tar.gz
```

⚠️ **Warning:** This will overwrite your current database!

### Change Odoo or PostgreSQL Version

**Supported Odoo versions:**
- `19.0` - Latest (Recommended for new deployments)
- `18.0` - LTS (Long Term Support - Best for production)
- `17.0` - Community Edition
- `16.0` - Community Edition

**Supported PostgreSQL versions:**
- `17` - Latest (Recommended for Odoo 18-19)
- `16` - Stable (Compatible with all Odoo versions)
- `15` - Stable (Compatible with all Odoo versions)
- `14` - Stable (Compatible with Odoo 16-17)

**To change versions:**

1. Edit `.env`:
```env
ODOO_VERSION=18.0      # Change to desired Odoo version
POSTGRES_VERSION=16    # Change to desired PostgreSQL version
```

2. Reload configuration:
```bash
./reload-config.sh
```

**Version Compatibility Matrix:**
| Odoo Version | Recommended PostgreSQL | Minimum PostgreSQL |
|--------------|------------------------|-------------------|
| 19.0         | 17                     | 14                |
| 18.0         | 16 or 17               | 14                |
| 17.0         | 15 or 16               | 12                |
| 16.0         | 14 or 15               | 12                |

⚠️ **Note:** Changing versions requires redeployment. Backup your data first!

---

## 📊 Monitoring & Management

### Visual Tools

**k9s (Terminal UI):**
```bash
k9s
```

**Kubernetes Dashboard (Web UI):**
```bash
./scripts/open-dashboard.sh
```

### Check Resource Usage

```bash
kubectl top pods -n odoo
kubectl top pods -n postgresql
kubectl top nodes
```

### Check Cluster Status

```bash
# All resources
kubectl get all --all-namespaces

# Specific namespace
kubectl get all -n odoo

# Ingress status
kubectl get ingress -n odoo
kubectl describe ingress odoo-ingress -n odoo
```

---

## 🔧 Troubleshooting

### Pods Not Starting

```bash
# Check pod status
kubectl get pods -n odoo

# Describe pod (shows events and errors)
kubectl describe pod <pod-name> -n odoo

# Check logs
kubectl logs <pod-name> -n odoo
```

### SSL Certificate Not Issued

```bash
# Check Traefik logs for ACME errors
kubectl logs -n traefik -l app=traefik | grep acme

# Verify ingress configuration
kubectl describe ingress odoo-ingress -n odoo

# Common issues:
# - DNS not pointing to LoadBalancer IP
# - Port 80/443 not accessible
# - Let's Encrypt rate limit (50 certs/week per domain)
```

### Odoo Can't Connect to PostgreSQL

```bash
# Check PostgreSQL service
kubectl get svc -n postgresql

# Test connection from Odoo pod
kubectl exec -it <odoo-pod> -n odoo -- \
  psql -h postgresql.postgresql.svc.cluster.local -U odoo -d postgres

# Check PostgreSQL logs
kubectl logs -n postgresql -l app=postgresql
```

### Storage Issues

```bash
# Check persistent volumes
kubectl get pv
kubectl get pvc -n odoo
kubectl get pvc -n postgresql

# Check storage usage
kubectl exec -n odoo <odoo-pod> -- df -h
```

### Backup Job Failed

```bash
# Check CronJob status
kubectl get cronjob -n backups

# View recent jobs
kubectl get jobs -n backups

# Check logs
kubectl logs -n backups -l job-name=odoo-backup --tail=100
```

---

## 📁 Project Structure

```
kubernetes-traefik/
├── traefik/              # Traefik Ingress Controller
│   ├── 00-namespace.yaml
│   ├── 01-rbac.yaml
│   ├── 02-crd.yaml
│   ├── 03-deployment.yaml
│   └── 04-service.yaml
├── postgresql/           # PostgreSQL StatefulSet
│   ├── 00-namespace.yaml
│   ├── 01-configmap.yaml
│   ├── 02-secret.yaml
│   ├── 03-pvc.yaml
│   └── 04-statefulset.yaml
├── odoo/                 # Odoo Deployment
│   ├── 00-namespace.yaml
│   ├── 01-configmap.yaml
│   ├── 02-secret.yaml
│   ├── 03-pvc.yaml
│   ├── 04-deployment.yaml
│   ├── 05-service.yaml
│   └── 06-ingress.yaml
├── backups/              # Backup CronJob
│   ├── 00-namespace.yaml
│   ├── 01-pvc.yaml
│   ├── 02-backup-script.yaml
│   └── 03-cronjob.yaml
├── scripts/              # Management scripts
│   ├── deploy-all.sh
│   ├── delete-all.sh
│   ├── setup-backups.sh
│   ├── backup-now.sh
│   ├── list-backups.sh
│   └── restore-backup.sh
├── install-everything.sh # One-command installer
├── install-kubernetes.sh # Kubernetes installer
├── setup-cluster.sh      # Cluster initialization
└── .env.example          # Configuration template
```

---

## ⚙️ Configuration Reference

### Environment Variables (.env)

```env
# Odoo Configuration
ODOO_DOMAIN=odoo.yourdomain.com
ODOO_VERSION=19.0                    # Options: 19.0, 18.0, 17.0, 16.0
ODOO_REPLICAS=1                      # Number of Odoo pods
ODOO_ADMIN_PASSWD=master_password    # Odoo master password

# PostgreSQL Configuration
POSTGRES_VERSION=17                  # Options: 17, 16, 15, 14
POSTGRES_USER=odoo
POSTGRES_PASSWORD=secure_password
POSTGRES_DB=postgres

# Let's Encrypt SSL
LETSENCRYPT_EMAIL=your-email@example.com

# Storage
ODOO_DATA_SIZE=20Gi                  # Odoo filestore size
POSTGRES_DATA_SIZE=10Gi              # PostgreSQL data size

# Backup Configuration
BACKUP_RETENTION_DAYS=7
BACKUP_SCHEDULE="0 2 * * *"          # Daily at 2:00 AM UTC
```

### Backup Schedule Examples

```yaml
# Every 6 hours
BACKUP_SCHEDULE="0 */6 * * *"

# Every 12 hours
BACKUP_SCHEDULE="0 */12 * * *"

# Daily at 3 AM
BACKUP_SCHEDULE="0 3 * * *"

# Weekly on Sunday at 2 AM
BACKUP_SCHEDULE="0 2 * * 0"
```

### Resource Limits

Edit `odoo/04-deployment.yaml`:
```yaml
resources:
  requests:
    memory: "1Gi"
    cpu: "500m"
  limits:
    memory: "2Gi"
    cpu: "1000m"
```

---

## 🔒 Security Best Practices

1. **Change default passwords** in `.env` before deployment
2. **Use strong passwords** (minimum 16 characters)
3. **Restrict SSH access** to your server
4. **Enable firewall** (allow only 80, 443, and SSH)
5. **Regular backups** and test restore procedures
6. **Update regularly** (Kubernetes, Odoo, PostgreSQL)
7. **Monitor logs** for suspicious activity
8. **Use NetworkPolicies** to restrict pod communication
9. **Enable RBAC** for fine-grained access control
10. **Encrypt backups** if storing offsite

### Enable Traefik Dashboard Authentication

Edit `traefik/03-deployment.yaml`:
```yaml
- --api.dashboard=true
- --api.insecure=false  # Disable insecure access
```

Create basic auth:
```bash
htpasswd -nb admin your_password | base64
```

Add to Traefik middleware.

---

## 📦 Backup System Details

### What Gets Backed Up

Each backup (`YYYYMMDD_HHMMSS_complete.tar.gz`) includes:

1. **PostgreSQL Database** - Full dump using `pg_dump`
2. **Odoo Filestore** - All attachments, images, documents
3. **Odoo Sessions** - Active user sessions (optional)
4. **Manifest** - Backup metadata and information

### Backup Contents

```
20251017_020000_complete.tar.gz
├── database.dump          # PostgreSQL database
├── filestore.tar.gz       # Odoo filestore
├── sessions.tar.gz        # User sessions
└── manifest.txt           # Backup metadata
```

### Backup to Cloud Storage

**AWS S3:**
```bash
# Add to backup script
aws s3 cp ${TIMESTAMP}.tar.gz s3://your-bucket/odoo-backups/
```

**Google Cloud Storage:**
```bash
# Add to backup script
gsutil cp ${TIMESTAMP}.tar.gz gs://your-bucket/odoo-backups/
```

---

## 🌐 Deployment Options

### Local Development (minikube)

```bash
# Start minikube
minikube start

# Deploy
./scripts/deploy-all.sh

# Access Odoo
minikube service odoo -n odoo
```

### Cloud Providers

#### Google Kubernetes Engine (GKE)

```bash
# Create cluster
gcloud container clusters create odoo-cluster \
  --num-nodes=3 \
  --machine-type=n1-standard-2

# Get credentials
gcloud container clusters get-credentials odoo-cluster

# Deploy
./scripts/deploy-all.sh
```

#### Amazon EKS

```bash
# Create cluster
eksctl create cluster \
  --name odoo-cluster \
  --region us-west-2 \
  --nodes 3

# Deploy
./scripts/deploy-all.sh
```

#### DigitalOcean Kubernetes

```bash
# Create cluster
doctl kubernetes cluster create odoo-cluster \
  --count 3 \
  --size s-2vcpu-4gb

# Get credentials
doctl kubernetes cluster kubeconfig save odoo-cluster

# Deploy
./scripts/deploy-all.sh
```

---

## 🚀 Advanced Operations

### Multi-Region Deployment

For high availability across regions, deploy to multiple clusters and use a global load balancer.

### Custom Odoo Addons

1. Create a custom Docker image with your addons
2. Update `ODOO_VERSION` in `.env` to your custom image
3. Redeploy: `./reload-config.sh`

### Monitoring with Prometheus + Grafana

```bash
# Install Prometheus Operator
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/bundle.yaml

# Install Grafana
kubectl apply -f monitoring/grafana.yaml
```

### CI/CD Integration

Use GitHub Actions, GitLab CI, or Jenkins to automate deployments:

```yaml
# .github/workflows/deploy.yml
name: Deploy to Kubernetes
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Deploy
        run: ./scripts/deploy-all.sh
```

---

## 📚 Useful Commands Cheat Sheet

```bash
# Cluster Management
kubectl cluster-info                    # Cluster info
kubectl get nodes                       # List nodes
kubectl top nodes                       # Node resource usage

# Pod Management
kubectl get pods -A                     # All pods
kubectl get pods -n odoo                # Odoo pods
kubectl describe pod <pod> -n odoo      # Pod details
kubectl logs <pod> -n odoo -f           # Follow logs
kubectl exec -it <pod> -n odoo -- bash  # Shell access

# Service Management
kubectl get svc -A                      # All services
kubectl get ingress -A                  # All ingresses

# Deployment Management
kubectl scale deployment odoo -n odoo --replicas=3  # Scale
kubectl rollout restart deployment odoo -n odoo     # Restart
kubectl rollout status deployment odoo -n odoo      # Status
kubectl rollout undo deployment odoo -n odoo        # Rollback

# Storage Management
kubectl get pv                          # Persistent volumes
kubectl get pvc -A                      # Persistent volume claims

# Backup Management
kubectl get cronjob -n backups          # Backup schedule
kubectl get jobs -n backups             # Backup jobs
./scripts/backup-now.sh                 # Manual backup
./scripts/list-backups.sh               # List backups
./scripts/restore-backup.sh <file>      # Restore

# Cleanup
./scripts/delete-all.sh                 # Delete all resources
kubectl delete namespace <namespace>    # Delete namespace
```

---

## 🆘 Getting Help

- **Email**: dmimbela@nlcode.com
- **Issues**: Create a GitHub issue
- **Documentation**: This README (you're reading it!)

---

## 📖 External Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [Odoo Documentation](https://www.odoo.com/documentation/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

---

## 📝 License

© 2025 Dustin Mimbela

---

## 🎉 You're All Set!

Your production-ready Odoo system is now running on Kubernetes with automatic SSL and daily backups.

**Next steps:**
1. Configure your Odoo instance
2. Install custom addons
3. Set up your company data
4. Train your team

**Happy Odoo!** 🚀
