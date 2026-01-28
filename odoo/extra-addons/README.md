# 📦 Odoo Extra Addons Directory

This directory is for your **custom Odoo modules** (addons).

## 📁 Structure

```
extra-addons/
├── README.md                    # This file
├── requirements.txt             # Python dependencies for your addons
├── your_custom_module/          # Your custom module
│   ├── __init__.py
│   ├── __manifest__.py
│   ├── models/
│   ├── views/
│   ├── security/
│   └── ...
└── another_module/              # Another custom module
    └── ...
```

## 🚀 How to Add Custom Modules

### Option 1: Copy Modules to This Directory

```bash
# Copy your module to extra-addons/
cp -r /path/to/your_module odoo/extra-addons/

# The structure should be:
# odoo/extra-addons/your_module/__manifest__.py
```

### Option 2: Clone from Git

```bash
cd odoo/extra-addons

# Clone a module from GitHub
git clone https://github.com/user/odoo-module.git

# Or clone specific branch
git clone -b 16.0 https://github.com/OCA/server-tools.git
```

### Option 3: Use Git Submodules (Recommended for Production)

```bash
cd odoo/extra-addons

# Add as submodule
git submodule add https://github.com/user/odoo-module.git

# Update submodules
git submodule update --init --recursive
```

## 📝 Python Dependencies

If your custom modules require Python libraries, add them to `requirements.txt`:

```txt
# Example dependencies
requests>=2.31.0
pandas>=2.0.0
openpyxl>=3.1.0
```

These will be automatically installed when the Odoo pod starts.

## 🔄 Deploying Custom Modules

### Step 1: Add Your Module

```bash
# Copy or clone your module to extra-addons/
cp -r /path/to/your_module odoo/extra-addons/
```

### Step 2: Update Kubernetes

```bash
# If using PersistentVolume, copy files to the volume
kubectl cp odoo/extra-addons/your_module odoo/odoo-pod:/mnt/extra-addons/

# Or rebuild and redeploy
kubectl rollout restart deployment odoo -n odoo
```

### Step 3: Install Module in Odoo

1. Go to Odoo web interface
2. Enable Developer Mode: Settings → Activate Developer Mode
3. Go to Apps → Update Apps List
4. Search for your module
5. Click Install

## 📦 Example Module Structure

Here's a minimal Odoo module structure:

```
your_module/
├── __init__.py              # Module initialization
├── __manifest__.py          # Module metadata
├── models/
│   ├── __init__.py
│   └── your_model.py        # Your model
├── views/
│   └── your_views.xml       # Your views
├── security/
│   ├── ir.model.access.csv  # Access rights
│   └── security.xml         # Security groups
├── data/
│   └── data.xml             # Demo/initial data
└── static/
    └── description/
        ├── icon.png         # Module icon
        └── index.html       # Module description
```

### Minimal `__manifest__.py`:

```python
{
    'name': 'Your Module Name',
    'version': '16.0.1.0.0',
    'category': 'Custom',
    'summary': 'Short description',
    'description': """
        Long description of your module.
    """,
    'author': 'Your Name',
    'website': 'https://yourwebsite.com',
    'license': 'LGPL-3',
    'depends': ['base', 'sale'],  # Dependencies
    'data': [
        'security/ir.model.access.csv',
        'views/your_views.xml',
    ],
    'installable': True,
    'application': False,
    'auto_install': False,
}
```

## 🔍 Troubleshooting

### Module Not Appearing in Apps List

```bash
# 1. Check module is in correct location
kubectl exec -it deployment/odoo -n odoo -- ls -la /mnt/extra-addons/

# 2. Check Odoo logs
kubectl logs -n odoo deployment/odoo -f

# 3. Update apps list in Odoo
# Settings → Apps → Update Apps List
```

### Import Errors

```bash
# Check if Python dependencies are installed
kubectl exec -it deployment/odoo -n odoo -- pip3 list

# Install missing dependencies
kubectl exec -it deployment/odoo -n odoo -- pip3 install your-package
```

### Permission Issues

```bash
# Fix permissions
kubectl exec -it deployment/odoo -n odoo -- chown -R odoo:odoo /mnt/extra-addons/
```

## 📚 Recommended OCA Modules

Here are some popular OCA (Odoo Community Association) modules:

```bash
cd odoo/extra-addons

# Server Tools
git clone -b 16.0 https://github.com/OCA/server-tools.git

# Web Modules
git clone -b 16.0 https://github.com/OCA/web.git

# Reporting
git clone -b 16.0 https://github.com/OCA/reporting-engine.git

# Account Financial Tools
git clone -b 16.0 https://github.com/OCA/account-financial-tools.git
```

## 🎯 Best Practices

1. **Version Control**: Use Git submodules for external modules
2. **Testing**: Test modules in development before production
3. **Dependencies**: Document all Python dependencies in requirements.txt
4. **Naming**: Use lowercase with underscores (e.g., `my_custom_module`)
5. **Manifest**: Always include proper `__manifest__.py`
6. **Security**: Always include `ir.model.access.csv`
7. **Documentation**: Add README.md in each module

## 🔗 Related Documentation

- [Odoo Module Development](https://www.odoo.com/documentation/16.0/developer/tutorials.html)
- [OCA Guidelines](https://github.com/OCA/odoo-community.org)
- [Main README](../../README.md)

---

**Custom Addons for Odoo on Kubernetes**
© 2025 Dustin Mimbela
