# 📦 Odoo Version Guide

## 🎯 Available Versions

### **Option 1: Docker Hub Images (Recommended for Production)**

Use official pre-built images from Docker Hub:

```env
ODOO_VERSION=17.0  # Stable releases only
ODOO_VERSION=16.0
ODOO_VERSION=15.0
ODOO_VERSION=14.0
```

**Pros:**
- ✅ Fast deployment (no build time)
- ✅ Tested and stable
- ✅ Smaller image size

**Cons:**
- ❌ Only major versions (17.0, 16.0, etc.)
- ❌ No SaaS versions (17.4, 17.3, etc.)

---

### **Option 2: Build from Source (For Specific Versions)**

Build from Odoo's GitHub repository to use specific SaaS versions:

```env
ODOO_VERSION=17.4  # SaaS versions
ODOO_VERSION=17.3
ODOO_VERSION=17.2
```

**Pros:**
- ✅ Access to latest SaaS versions (17.4, 17.3, etc.)
- ✅ More features and bug fixes
- ✅ Customizable

**Cons:**
- ❌ Longer deployment time (needs to build)
- ❌ Requires building custom Docker image
- ❌ Larger image size

---

## 🚀 How to Use

### **For Docker Hub Versions (17.0, 16.0, etc.):**

1. Edit `.env`:
   ```env
   ODOO_VERSION=17.0
   ```

2. Deploy:
   ```bash
   ./install-odoo.sh
   ```

---

### **For Source Code Versions (17.4, 17.3, etc.):**

1. Build custom Docker image:
   ```bash
   cd odoo
   docker build -t myodoo:17.4 --build-arg ODOO_VERSION=17.4 -f Dockerfile.custom .
   
   # Push to your registry (optional)
   docker tag myodoo:17.4 your-registry/odoo:17.4
   docker push your-registry/odoo:17.4
   ```

2. Update `odoo/02-deployment.yaml`:
   ```yaml
   image: myodoo:17.4  # or your-registry/odoo:17.4
   ```

3. Deploy:
   ```bash
   kubectl apply -f odoo/02-deployment.yaml
   ```

---

## 📋 Available Branches

Check available versions at:
- **Docker Hub**: https://hub.docker.com/_/odoo/tags
- **GitHub Branches**: https://github.com/odoo/odoo/branches

Common SaaS branches:
- `saas-17.4`
- `saas-17.3`
- `saas-17.2`
- `saas-16.4`
- etc.

---

## 💡 Recommendation

- **Production**: Use Docker Hub versions (17.0, 16.0)
- **Testing/Development**: Use source code versions (17.4, 17.3)
- **Latest Features**: Use latest SaaS branch (17.4)

---

## 🔧 DB Filter Configuration

The `dbfilter = ^%d$` in `odoo.conf` means:
- Odoo will automatically select the database matching the domain
- Example: `mycompany.odoo.com` → database `mycompany`
- No database selection screen for users

To customize:
```bash
nano odoo/01-configmap.yaml
```

Change `dbfilter`:
- `^%d$` - Match domain name
- `^.*$` - Show all databases
- `^mydb$` - Only show specific database
