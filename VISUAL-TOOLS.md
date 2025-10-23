# 🎨 Visual Tools for Kubernetes

Two ways to see what's happening in your Kubernetes cluster visually.

## 🖥️ Option 1: k9s (Terminal UI) - Recommended

**Super fast and easy to use!**

### Install

```bash
chmod +x scripts/install-k9s.sh
sudo ./scripts/install-k9s.sh
```

### Launch

```bash
k9s
```

### What You See

```
┌─────────────────────────────────────────────┐
│ Pods (all namespaces)                       │
├─────────────────────────────────────────────┤
│ ✓ traefik-xxx         Running   1/1         │
│ ✓ postgresql-0        Running   1/1         │
│ ✓ odoo-xxx            Running   1/1         │
│ ✓ odoo-backup-xxx     Completed 0/1         │
└─────────────────────────────────────────────┘
```

### Keyboard Shortcuts

- `0` - Show all namespaces
- `:pods` - View pods
- `:svc` - View services
- `:deploy` - View deployments
- `l` - View logs
- `d` - Describe resource
- `?` - Help
- `Ctrl+C` - Exit

### Screenshots

**Main view:**
- See all pods, their status, restarts
- Green = Running, Red = Error
- Real-time updates

**Logs view:**
- Press `l` on any pod
- See live logs
- Auto-scrolling

---

## 🌐 Option 2: Kubernetes Dashboard (Web UI)

**Full-featured web interface**

### Install

```bash
./scripts/install-dashboard.sh
```

### Open

```bash
./scripts/open-dashboard.sh
```

This will:
1. Generate your access token
2. Start the proxy
3. Show you the URL

### Access

1. Copy the token shown
2. Open: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
3. Select "Token" login
4. Paste token
5. Click "Sign In"

### What You See

- 📊 **Overview**: Cluster health, resource usage
- 🔷 **Workloads**: Pods, Deployments, StatefulSets
- 🌐 **Services**: Services, Ingresses
- ⚙️ **Config**: ConfigMaps, Secrets
- 💾 **Storage**: PersistentVolumes, Claims
- 📈 **Metrics**: CPU, Memory usage graphs

---

## 🆚 Comparison

| Feature | k9s | Dashboard |
|---------|-----|-----------|
| Speed | ⚡ Instant | 🐢 Slower |
| Interface | Terminal | Web Browser |
| Resource Usage | 💚 Low | 🟡 Medium |
| Learning Curve | Easy | Medium |
| Features | Basic | Advanced |
| Best For | Quick checks | Deep analysis |

## 💡 Recommended Workflow

### Daily Use: k9s
```bash
k9s
```
- Quick status check
- View logs
- Restart pods
- Check resources

### Deep Dive: Dashboard
```bash
./scripts/open-dashboard.sh
```
- Analyze metrics
- Edit configurations
- View detailed graphs
- Troubleshoot issues

---

## 📸 What You Can See

### Pod Status
- ✅ Running pods (green)
- ⚠️ Pending pods (yellow)
- ❌ Failed pods (red)
- 🔄 Restarting pods

### Resource Usage
- 📊 CPU usage per pod
- 💾 Memory usage per pod
- 📈 Historical graphs
- ⚡ Real-time updates

### Logs
- 📝 Live streaming logs
- 🔍 Search in logs
- 📥 Download logs
- 🎯 Filter by pod/container

### Network
- 🌐 Services and endpoints
- 🔗 Ingress rules
- 📡 Load balancer status
- 🔌 Port mappings

---

## 🚀 Quick Start Examples

### Check if Odoo is running

**k9s:**
```
1. Launch: k9s
2. Type: :pods
3. Filter: /odoo
4. Look for green "Running" status
```

**Dashboard:**
```
1. Open dashboard
2. Select "odoo" namespace
3. Click "Pods"
4. See status and metrics
```

### View Odoo logs

**k9s:**
```
1. Launch: k9s
2. Navigate to odoo pod
3. Press: l
4. See live logs
```

**Dashboard:**
```
1. Open dashboard
2. Go to Pods
3. Click on odoo pod
4. Click "Logs" icon
```

### Check backup status

**k9s:**
```
1. Launch: k9s
2. Type: :jobs
3. Filter: /backup
4. See completion status
```

**Dashboard:**
```
1. Open dashboard
2. Select "backups" namespace
3. Click "Jobs"
4. See job history
```

---

## 🎓 Learn More

### k9s
- Documentation: https://k9scli.io/
- Keyboard shortcuts: Press `?` in k9s

### Kubernetes Dashboard
- Documentation: https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/
- GitHub: https://github.com/kubernetes/dashboard

---

**Visual Monitoring Made Easy**
© 2025 Dustin Mimbela
