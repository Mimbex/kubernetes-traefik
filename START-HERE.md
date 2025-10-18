# 🚀 Start Here - Complete Guide

**Never used Kubernetes before? No problem!** This guide will take you from zero to a production-ready Odoo deployment.

## 📋 What You'll Get

- ✅ Kubernetes cluster (local or cloud)
- ✅ Odoo 19 with SSL certificates
- ✅ PostgreSQL 17 database
- ✅ Automatic daily backups
- ✅ Professional setup in ~15 minutes

## 🎯 Step-by-Step Guide

### Step 1: Install Kubernetes (5 minutes)

**On macOS:**
```bash
chmod +x install-kubernetes-macos.sh
./install-kubernetes-macos.sh
```

**On Linux:**
```bash
chmod +x install-kubernetes.sh
./install-kubernetes.sh
```

This installs:
- kubectl (Kubernetes CLI)
- minikube (local Kubernetes)
- Docker (container runtime)

### Step 2: Start Kubernetes Cluster (2 minutes)

```bash
# Start minikube
minikube start

# Verify it's running
kubectl cluster-info
```

You should see:
```
Kubernetes control plane is running at https://...
```

### Step 3: Configure Your Setup (3 minutes)

```bash
# Copy configuration template
cp .env.example .env

# Edit configuration
nano .env
```

**Minimum required changes:**
```env
ODOO_DOMAIN=odoo.yourdomain.com
LETSENCRYPT_EMAIL=your-email@example.com
```

For local testing, you can use:
```env
ODOO_DOMAIN=odoo.local
LETSENCRYPT_EMAIL=test@example.com
```

### Step 4: Deploy Everything (5 minutes)

```bash
# Deploy Odoo, PostgreSQL, and Traefik
./scripts/deploy-all.sh

# Setup automated backups (optional)
./scripts/setup-backups.sh
```

Wait for all pods to be ready:
```bash
kubectl get pods --all-namespaces
```

### Step 5: Access Odoo

**For local development (minikube):**
```bash
# Get the service URL
minikube service odoo -n odoo

# Or get the IP
minikube ip
```

**For production (cloud):**
```bash
# Get LoadBalancer IP
kubectl get svc traefik -n traefik

# Point your domain to this IP
# Then access: https://odoo.yourdomain.com
```

## 🎓 What Just Happened?

1. **Traefik** - Handles HTTPS and routes traffic
2. **PostgreSQL** - Stores all Odoo data
3. **Odoo** - Your ERP system
4. **Backups** - Daily automated backups

## 📚 Next Steps

### Learn the Basics

```bash
# View all resources
kubectl get all --all-namespaces

# Check pod logs
kubectl logs -n odoo -l app=odoo -f

# Access Odoo pod
kubectl exec -it -n odoo <pod-name> -- bash
```

### Common Tasks

**Run manual backup:**
```bash
./scripts/backup-now.sh
```

**List backups:**
```bash
./scripts/list-backups.sh
```

**Scale Odoo:**
```bash
kubectl scale deployment odoo -n odoo --replicas=3
```

**Update Odoo:**
```bash
./scripts/update-odoo.sh
```

## 🆘 Troubleshooting

### Pods not starting?

```bash
# Check pod status
kubectl get pods -n odoo

# Check pod details
kubectl describe pod <pod-name> -n odoo

# Check logs
kubectl logs <pod-name> -n odoo
```

### Can't access Odoo?

```bash
# Check services
kubectl get svc --all-namespaces

# For minikube, use:
minikube service list
```

### SSL certificate not working?

```bash
# Check Traefik logs
kubectl logs -n traefik -l app=traefik

# Verify ingress
kubectl get ingress -n odoo
kubectl describe ingress odoo-ingress -n odoo
```

## 📖 Documentation

- [INSTALL.md](INSTALL.md) - Detailed installation guide
- [QUICKSTART.md](QUICKSTART.md) - Quick reference
- [CONFIGURATION.md](CONFIGURATION.md) - Configuration options
- [BACKUPS.md](BACKUPS.md) - Backup & restore guide
- [README.md](README.md) - Complete documentation

## 💡 Tips for Beginners

### Learn kubectl

```bash
# Get help
kubectl --help

# Get resource types
kubectl api-resources

# Explain resources
kubectl explain pod
kubectl explain deployment
```

### Use k9s (Optional)

k9s is a terminal UI for Kubernetes:

```bash
# Install
brew install k9s  # macOS
# or visit: https://k9scli.io/

# Run
k9s
```

### Enable autocomplete

```bash
# Zsh (macOS default)
echo 'source <(kubectl completion zsh)' >> ~/.zshrc
source ~/.zshrc

# Bash
echo 'source <(kubectl completion bash)' >> ~/.bashrc
source ~/.bashrc
```

## 🎯 Production Checklist

Before going to production:

- [ ] Change default passwords in `.env`
- [ ] Use a real domain name
- [ ] Configure DNS properly
- [ ] Test backups and restore
- [ ] Set up monitoring (optional)
- [ ] Configure resource limits
- [ ] Enable network policies
- [ ] Review security settings

## 🌟 What's Next?

### Local Development
- Perfect for testing and development
- Use minikube
- Free and easy

### Production Deployment
- Use cloud provider (GKE, EKS, AKS, DO)
- Better performance
- High availability
- Automatic scaling

### Advanced Features
- Add monitoring (Prometheus + Grafana)
- Set up CI/CD
- Multi-region deployment
- Custom addons development

## 🤝 Need Help?

- 📧 Email: dmimbela@nlcode.com
- 📚 Documentation: See links above
- 🐛 Issues: Create GitHub issue

---

**From Zero to Production in 15 Minutes**
© 2025 Dustin Mimbela

🎉 **You're ready to go! Happy Odoo!** 🎉
