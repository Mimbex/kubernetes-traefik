# 📦 Installing Python Dependencies in Odoo

## 🎯 How It Works

Odoo automatically installs Python dependencies from a `requirements.txt` file located in `/opt/odoo-extra-addons/` on the server.

---

## 📝 Adding Dependencies

### **Method 1: Create requirements.txt on the server**

```bash
# SSH to server
ssh root@your-server

# Create or edit requirements.txt
nano /opt/odoo-extra-addons/requirements.txt
```

Add your dependencies:
```txt
requests==2.31.0
pandas==2.0.3
openpyxl==3.1.2
pillow==10.0.0
reportlab==4.0.4
```

Save and restart Odoo:
```bash
cd /opt/kubernetes-traefik
./restart-odoo.sh
```

---

### **Method 2: Include requirements.txt in your module**

If your custom module needs specific dependencies, include a `requirements.txt` in your module folder:

```
/opt/odoo-extra-addons/
├── my_custom_module/
│   ├── __init__.py
│   ├── __manifest__.py
│   ├── requirements.txt  ← Add this
│   └── ...
└── requirements.txt  ← Or add here for all modules
```

---

## 🔄 Installing Dependencies

Dependencies are installed automatically when Odoo starts using an **InitContainer**.

### **Manual restart to install new dependencies:**

```bash
./restart-odoo.sh
```

### **View installation logs:**

```bash
# See if dependencies were installed
kubectl logs -n odoo -l app=odoo -c install-requirements

# See Odoo logs
kubectl logs -n odoo deployment/odoo -f
```

---

## 📋 Common Dependencies

### **Excel/Spreadsheet:**
```txt
openpyxl==3.1.2
xlrd==2.0.1
xlwt==1.3.0
```

### **PDF Generation:**
```txt
reportlab==4.0.4
pypdf2==3.0.1
```

### **Image Processing:**
```txt
pillow==10.0.0
```

### **API/Web:**
```txt
requests==2.31.0
```

### **Data Processing:**
```txt
pandas==2.0.3
numpy==1.24.3
```

### **Barcode/QR:**
```txt
python-barcode==0.15.1
qrcode==7.4.2
```

---

## ⚠️ Important Notes

1. **Version pinning**: Always specify versions (e.g., `requests==2.31.0`) to avoid compatibility issues
2. **Restart required**: After adding dependencies, run `./restart-odoo.sh`
3. **Installation time**: First restart may take longer while installing packages
4. **Persistent**: Dependencies persist across pod restarts (installed on each start)

---

## 🔍 Troubleshooting

### **Dependencies not installing:**

```bash
# Check init container logs
kubectl logs -n odoo -l app=odoo -c install-requirements

# Check if requirements.txt exists
ls -la /opt/odoo-extra-addons/requirements.txt
```

### **Module import errors:**

```bash
# See Odoo logs for Python errors
kubectl logs -n odoo deployment/odoo -f
```

### **Reinstall dependencies:**

```bash
# Delete pod to force reinstall
kubectl delete pod -n odoo -l app=odoo

# Or restart
./restart-odoo.sh
```

---

## 📂 File Locations

| Location | Purpose |
|----------|---------|
| `/opt/odoo-extra-addons/requirements.txt` | Global dependencies for all modules |
| `/opt/odoo-extra-addons/my_module/requirements.txt` | Module-specific dependencies |

---

## ✅ Example Workflow

```bash
# 1. SSH to server
ssh root@your-server

# 2. Create requirements.txt
cat > /opt/odoo-extra-addons/requirements.txt << EOF
requests==2.31.0
openpyxl==3.1.2
pillow==10.0.0
EOF

# 3. Restart Odoo
cd /opt/kubernetes-traefik
./restart-odoo.sh

# 4. Check logs
kubectl logs -n odoo -l app=odoo -c install-requirements
```

Done! Your dependencies are installed. 🎉
