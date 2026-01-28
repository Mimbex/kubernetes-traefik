# 🚀 Odoo 19 on Kubernetes (Production Ready)

**The ultimate guide to deploying Odoo 19 on Linux using MicroK8s.**
*Simple. Scalable. Automated.*

---

## ✨ Features
- ✅ **MicroK8s:** Lightweight, production-grade Kubernetes.
- ✅ **Odoo 19:** Latest ERP version/
- ✅ **PostgreSQL 17:** High-performance database.
- ✅ **Traefik:** Automatic HTTPS (Let's Encrypt).
- ✅ **Auto-Fix Permissions:** Solves common addon permission issues automatically.
- ✅ **Persistent Storage:** Keeps your data safe even if you destroy the cluster.

---

## 🎥 Installation Video Guide

Follow these steps along with the video tutorial.

### 0. ☢️ Preparation (Clean Slate)
**WARNING:** Only run this if you want to wipe the server and start from zero.
```bash
./scripts/nuke-everything.sh
```

### 1. 🏗️ Install Infrastructure (MicroK8s)
Installs Kubernetes, enables DNS, Ingress, and Storage.
```bash
chmod +x scripts/*.sh
./scripts/install-microk8s.sh
```
*Wait until it says "Kubernetes Ready!"*

### 2. ⚙️ Configuration
Setup your domain and version.
```bash
cp .env.example .env
nano .env
```
**Change these variables:**
- `DOMAIN`: Your actual domain (e.g. `odoo.example.com`)
- `ODOO_VERSION`: `19.0`

### 3. 🚀 Deploy Stack
Launches Postgres, Odoo, and Traefik in correct order.
```bash
./scripts/deploy-all.sh
```

### 4. ✅ Verify
Check if everything is running:
```bash
kubectl get pods -A
```
Access your site at: `https://your-domain.com`.

---

## 🛠️ Management & Addons

### How to Install Custom Modules?
1. Upload your module folder to `/opt/extra-addons` on the server (e.g. via FileZilla).
2. Run the restart script to apply changes and fix permissions automatically:
   ```bash
   ./restart.sh
   ```
   *(Or running: `kubectl rollout restart deployment odoo -n odoo`)*
3. Go to Odoo -> Apps -> **Update Apps List** -> Install.

### How to Check Logs?
```bash
# Odoo Logs
kubectl logs -n odoo -l app=odoo -f

# Traefik Logs (for SSL issues)
kubectl logs -n traefik -l app=traefik -f
```

---

## 📋 File Structure
- `odoo/`: Kubernetes manifests for Odoo.
- `postgresql/`: Manifests for Database.
- `traefik/`: Manifests for Ingress Controller.
- `scripts/`: Automation tools.
  - `nuke-everything.sh`: Reset server.
  - `install-microk8s.sh`: Install K8s.
  - `deploy-all.sh`: Deploy everything.
  - `restart-odoo.sh`: Restart Odoo pods.

---

**Enjoy your Odoo 19 Cluster! 🚀**
