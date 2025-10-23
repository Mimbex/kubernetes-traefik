# Kubernetes + Traefik + Odoo 19 + PostgreSQL

Production-ready Kubernetes deployment with Traefik Ingress Controller, automatic SSL certificates with Let's Encrypt, PostgreSQL 17, and Odoo 19.

## 📋 Project Structure

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
├── scripts/              # Management scripts
│   ├── deploy-all.sh
│   ├── delete-all.sh
│   └── update-odoo.sh
└── README.md
```

## 🚀 Prerequisites

### Option 1: Install Kubernetes on Linux Server

**Production installation script (Ubuntu/Debian/CentOS/RHEL):**
```bash
chmod +x install-kubernetes.sh
sudo ./install-kubernetes.sh
```

This will install kubeadm, kubelet, kubectl, and containerd.

See [INSTALL.md](INSTALL.md) for detailed installation guide.

**For local development on macOS:** Use Docker Desktop with Kubernetes enabled.

### Option 2: Use existing cluster

- Kubernetes cluster (1.24+)
- kubectl configured
- Domain pointing to your cluster
- Ports 80 and 443 accessible

## 📦 Super Simple Installation (Recommended)

### Step 1: Install Kubernetes + Dashboard

**Install Kubernetes with visual tools:**

```bash
chmod +x install-kubernetes-complete.sh
sudo ./install-kubernetes-complete.sh
```

This script installs:
1. ✅ Kubernetes cluster
2. ✅ Network configuration
3. ✅ k9s (Terminal UI)
4. ✅ Kubernetes Dashboard (Web UI)

⏱️ Takes 5-8 minutes.

### Step 2: Deploy Odoo + Backups

**Deploy Odoo stack:**

```bash
chmod +x install-odoo.sh
./install-odoo.sh
```

This script installs:
1. ✅ Odoo 19
2. ✅ PostgreSQL 17
3. ✅ Traefik with SSL
4. ✅ Automated backups

⏱️ Takes 5-7 minutes.

---

## 📦 Manual Installation (Advanced)

### 1. Clone the repository

```bash
git clone https://github.com/yourusername/kubernetes-traefik.git
cd kubernetes-traefik
```

### 2. Install Kubernetes

```bash
chmod +x install-kubernetes.sh
sudo ./install-kubernetes.sh
```

### 3. Setup cluster

```bash
chmod +x setup-cluster.sh
sudo ./setup-cluster.sh
```

### 4. Configure environment

```bash
cp .env.example .env
nano .env  # Edit your domain and email
```

### 5. Deploy Odoo

```bash
./scripts/deploy-all.sh
```

### 4. Setup Automated Backups (Optional but Recommended)

```bash
./scripts/setup-backups.sh
```

This will configure:
- Daily backups at 2:00 AM UTC
- 7-day retention policy
- 50GB backup storage

See [BACKUPS.md](BACKUPS.md) for full documentation.

### 5. Check deployment status

```bash
kubectl get pods -n traefik
kubectl get pods -n postgresql
kubectl get pods -n odoo
kubectl get cronjob -n backups  # If backups are enabled
```

## 🌐 Access Services

- **Odoo**: `https://odoo.yourdomain.com`
- **Traefik Dashboard**: `https://traefik.yourdomain.com` (if enabled)

## ⚙️ Configuration

### PostgreSQL

- **Namespace**: `postgresql`
- **Storage**: 10Gi PersistentVolume
- **Version**: PostgreSQL 17
- **Service**: `postgresql.postgresql.svc.cluster.local:5432`

### Odoo

- **Namespace**: `odoo`
- **Replicas**: 1 (can be scaled)
- **Storage**: 10Gi for filestore
- **Version**: Odoo 19

### Traefik

- **Namespace**: `traefik`
- **Type**: LoadBalancer
- **Ports**: 80 (HTTP), 443 (HTTPS)
- **SSL**: Automatic with Let's Encrypt

## 🛠️ Management Scripts

### Deployment

- `deploy-all.sh` - Deploy all services
- `delete-all.sh` - Delete all resources
- `update-odoo.sh` - Update Odoo deployment

### Backups

- `setup-backups.sh` - Configure automated backups
- `backup-now.sh` - Run manual backup
- `list-backups.sh` - List available backups
- `restore-backup.sh` - Restore from backup

See [BACKUPS.md](BACKUPS.md) for detailed backup documentation.

## 🔧 Management Commands

### Deploy all services

```bash
./scripts/deploy-all.sh
```

### Delete all services

```bash
./scripts/delete-all.sh
```

### Update Odoo

```bash
./scripts/update-odoo.sh
```

### View logs

```bash
# Traefik logs
kubectl logs -n traefik -l app=traefik -f

# PostgreSQL logs
kubectl logs -n postgresql -l app=postgresql -f

# Odoo logs
kubectl logs -n odoo -l app=odoo -f
```

### Scale Odoo

```bash
kubectl scale deployment odoo -n odoo --replicas=3
```

## 🔒 Security Best Practices

1. **Change default passwords** in secret files
2. **Use strong passwords** for PostgreSQL
3. **Enable Traefik dashboard authentication** (basic auth)
4. **Use NetworkPolicies** to restrict traffic
5. **Enable RBAC** for fine-grained access control
6. **Regular backups** of PostgreSQL data

## 📊 Monitoring

### Check resource usage

```bash
kubectl top pods -n odoo
kubectl top pods -n postgresql
kubectl top pods -n traefik
```

### Check ingress status

```bash
kubectl get ingress -n odoo
kubectl describe ingress odoo-ingress -n odoo
```

## 🐛 Troubleshooting

### Pods not starting

```bash
kubectl describe pod <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace>
```

### SSL certificate not issued

```bash
kubectl logs -n traefik -l app=traefik | grep acme
```

### Odoo can't connect to PostgreSQL

```bash
# Check PostgreSQL service
kubectl get svc -n postgresql

# Test connection from Odoo pod
kubectl exec -it <odoo-pod> -n odoo -- psql -h postgresql.postgresql.svc.cluster.local -U odoo
```

### Storage issues

```bash
kubectl get pv
kubectl get pvc -n odoo
kubectl get pvc -n postgresql
```

## 📝 Important Notes

1. **DNS**: Ensure your domain points to the LoadBalancer IP
2. **Storage**: Configure StorageClass according to your cloud provider
3. **Backups**: Implement regular PostgreSQL backups
4. **Scaling**: Odoo filestore must be shared when scaling (use NFS or S3)
5. **Let's Encrypt**: Rate limit of 50 certificates per domain per week

## 🔄 Updates

### Update Odoo image

```bash
# Edit odoo/04-deployment.yaml and change image version
kubectl apply -f odoo/04-deployment.yaml
kubectl rollout status deployment odoo -n odoo
```

### Rollback deployment

```bash
kubectl rollout undo deployment odoo -n odoo
```

## 📚 Documentation

- [QUICKSTART.md](QUICKSTART.md) - Quick start guide
- [CONFIGURATION.md](CONFIGURATION.md) - Configuration guide
- [BACKUPS.md](BACKUPS.md) - Backup & restore guide

## 🔗 External Resources

- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Odoo Documentation](https://www.odoo.com/documentation/)
- [PostgreSQL on Kubernetes](https://www.postgresql.org/docs/)

## 📧 Support

For issues or questions, contact: dmimbela@nlcode.com

---

**Production-ready Kubernetes deployment for Odoo 19**
© 2025 Dustin Mimbela
