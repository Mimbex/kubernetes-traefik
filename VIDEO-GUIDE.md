# 🎥 Video Tutorial Guide

Two separate videos for easy learning.

## 📹 Video 1: Kubernetes + Dashboard (5-8 minutes)

### What You'll Install
- ✅ Kubernetes cluster
- ✅ k9s (Terminal UI)
- ✅ Kubernetes Dashboard (Web UI)

### Commands

```bash
# Download repository
git clone https://github.com/yourusername/kubernetes-traefik.git
cd kubernetes-traefik

# Install Kubernetes + Dashboard
chmod +x install-kubernetes-complete.sh
sudo ./install-kubernetes-complete.sh
```

### What to Show in Video

1. **Introduction** (30 sec)
   - What is Kubernetes
   - Why use it for Odoo

2. **Installation** (3 min)
   - Run the script
   - Show installation progress
   - Explain what's being installed

3. **Visual Tools** (2 min)
   - Launch k9s: `k9s`
   - Show pods, services, deployments
   - Open Dashboard: `./scripts/open-dashboard.sh`
   - Navigate the web interface

4. **Verification** (1 min)
   - `kubectl get nodes`
   - `kubectl get pods -A`
   - Show cluster is ready

5. **Outro** (30 sec)
   - Kubernetes is ready
   - Next video: Deploy Odoo

### Key Points to Mention
- ⚡ One command installation
- 🎨 Two visual tools (k9s + Dashboard)
- 🚀 Production-ready cluster
- 📊 Easy monitoring

---

## 📹 Video 2: Odoo + Backups (5-7 minutes)

### What You'll Install
- ✅ Odoo 19
- ✅ PostgreSQL 17
- ✅ Traefik with SSL
- ✅ Automated backups

### Commands

```bash
# Deploy Odoo stack
chmod +x install-odoo.sh
./install-odoo.sh

# Enter your domain when prompted
# Enter your email for SSL
```

### What to Show in Video

1. **Introduction** (30 sec)
   - Recap: Kubernetes is ready
   - Now deploying Odoo

2. **Configuration** (1 min)
   - Script asks for domain
   - Script asks for email
   - Explain why these are needed

3. **Deployment** (3 min)
   - Show deployment progress
   - Explain what's being deployed
   - Show pods starting in k9s

4. **Verification** (2 min)
   - Check pods: `kubectl get pods -A`
   - View in k9s
   - View in Dashboard
   - Show Odoo logs

5. **Backups** (1 min)
   - Explain automated backups
   - Show backup commands:
     - `./scripts/backup-now.sh`
     - `./scripts/list-backups.sh`

6. **Access Odoo** (1 min)
   - Show DNS configuration
   - Access Odoo URL
   - Show login screen

7. **Outro** (30 sec)
   - Everything is ready
   - Production-ready setup
   - Daily backups enabled

### Key Points to Mention
- 🚀 One command deployment
- 🔒 Automatic SSL certificates
- 💾 Daily automated backups
- 📊 Visual monitoring included

---

## 🎬 Video Production Tips

### Recording Setup
- Use terminal with large font (16-18pt)
- Dark theme for better visibility
- Screen resolution: 1920x1080
- Record at 30fps minimum

### Terminal Commands
```bash
# Make text larger
# macOS: Cmd + Plus
# Linux: Ctrl + Plus

# Clear screen before each command
clear

# Use comments to explain
echo "Installing Kubernetes..."
```

### Editing Tips
- Speed up installation parts (2x)
- Add text overlays for key points
- Highlight important terminal output
- Add background music (low volume)

### Thumbnail Ideas

**Video 1:**
```
┌─────────────────────────────┐
│  KUBERNETES + DASHBOARD     │
│  ⚡ ONE COMMAND INSTALL     │
│  🎨 VISUAL MONITORING       │
└─────────────────────────────┘
```

**Video 2:**
```
┌─────────────────────────────┐
│  ODOO 19 + BACKUPS          │
│  🚀 PRODUCTION READY        │
│  💾 AUTO BACKUPS            │
└─────────────────────────────┘
```

---

## 📝 Video Descriptions

### Video 1 Description

```
🚀 Install Kubernetes with Dashboard in 5 Minutes!

Learn how to install a production-ready Kubernetes cluster with visual monitoring tools.

⏱️ Timestamps:
00:00 - Introduction
00:30 - What is Kubernetes
01:00 - Installation command
01:30 - Installation process
04:00 - k9s Terminal UI
05:00 - Kubernetes Dashboard
06:30 - Verification
07:00 - Outro

✅ What You Get:
- Kubernetes cluster
- k9s (Terminal UI)
- Kubernetes Dashboard (Web UI)
- Production-ready setup

📦 Commands:
git clone https://github.com/yourusername/kubernetes-traefik.git
cd kubernetes-traefik
chmod +x install-kubernetes-complete.sh
sudo ./install-kubernetes-complete.sh

📚 Resources:
- GitHub: [link]
- Documentation: [link]
- Next Video: Odoo Installation

#Kubernetes #DevOps #Tutorial #k9s #Dashboard
```

### Video 2 Description

```
🚀 Deploy Odoo 19 on Kubernetes with Automated Backups!

Complete Odoo deployment with PostgreSQL, SSL certificates, and daily backups.

⏱️ Timestamps:
00:00 - Introduction
00:30 - Prerequisites check
01:00 - Configuration
02:00 - Deployment process
05:00 - Verification
06:00 - Backup system
07:00 - Accessing Odoo
08:00 - Outro

✅ What You Get:
- Odoo 19 ERP
- PostgreSQL 17
- Traefik with SSL
- Daily automated backups

📦 Commands:
chmod +x install-odoo.sh
./install-odoo.sh

📚 Resources:
- GitHub: [link]
- Documentation: [link]
- Previous Video: Kubernetes Setup

#Odoo #Kubernetes #ERP #Backups #Production
```

---

## 🎯 Target Audience

### Video 1
- DevOps beginners
- System administrators
- Developers learning Kubernetes
- People wanting visual tools

### Video 2
- Odoo users
- Business owners
- IT managers
- People deploying ERP systems

---

**Video Production Guide**
© 2025 Dustin Mimbela
