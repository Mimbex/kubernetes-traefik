# 🐳 Custom Odoo Docker Image

This directory contains the configuration for building a **custom Odoo Docker image** with all your specific dependencies.

## 📦 What's Included

### System Dependencies
- XML and security libraries (for electronic invoicing)
- Python development tools
- QR Code support
- Utilities (git, nano, ping)

### Python Libraries
- **Peruvian Localization (CPE)**: SUNAT SOAP client, librecpe
- **Panamanian Localization (FEL)**: pyCFE
- **Excel Processing**: openpyxl
- **PDF Processing**: pdf2image, img2pdf, fpdf2
- **Testing Tools**: odoo-test-helper, openupgradelib

## 🚀 Quick Start

### Option 1: Build Locally (Recommended for Development)

```bash
cd odoo

# Build for Odoo 19.0 (default)
./build-custom-image.sh

# Build for specific version
./build-custom-image.sh 18.0
./build-custom-image.sh 17.0
./build-custom-image.sh 16.0
```

### Option 2: Use Pre-built Image (Production)

If you have a Docker registry:

```bash
# Build and tag
./build-custom-image.sh 19.0
docker tag custom-odoo:19.0 your-registry.com/custom-odoo:19.0

# Push to registry
docker push your-registry.com/custom-odoo:19.0
```

## 📝 Adding Custom Dependencies

### Python Libraries

Edit `requirements.txt`:

```txt
# Add your library
your-library==1.0.0

# Or from git
git+https://github.com/user/repo.git@branch
```

### System Packages

Edit `Dockerfile.custom` in the `apt-get install` section:

```dockerfile
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    your-package \
    another-package \
    && rm -rf /var/lib/apt/lists/*
```

## 🔧 Using the Custom Image

### Update Kubernetes Deployment

Edit `02-deployment.yaml`:

```yaml
spec:
  template:
    spec:
      containers:
      - name: odoo
        image: custom-odoo:19.0  # Use your custom image
        # or from registry:
        # image: your-registry.com/custom-odoo:19.0
```

### Rebuild and Deploy

```bash
# 1. Build new image
cd odoo
./build-custom-image.sh 19.0

# 2. Update deployment
cd ..
kubectl apply -f odoo/02-deployment.yaml

# 3. Restart pods
kubectl rollout restart deployment odoo -n odoo
```

## 📊 Image Versions

| Odoo Version | Base Image | Custom Image Tag |
|--------------|------------|------------------|
| 19.0         | odoo:19.0  | custom-odoo:19.0 |
| 18.0         | odoo:18.0  | custom-odoo:18.0 |
| 17.0         | odoo:17.0  | custom-odoo:17.0 |
| 16.0         | odoo:16.0  | custom-odoo:16.0 |

## 🔍 Troubleshooting

### Build Fails

```bash
# Check Docker is running
docker ps

# Clean build cache
docker builder prune

# Rebuild without cache
docker build --no-cache --build-arg ODOO_VERSION=19.0 -t custom-odoo:19.0 -f Dockerfile.custom .
```

### Library Conflicts

If you have version conflicts:

1. Check `requirements.txt` for duplicate libraries
2. Pin specific versions: `library==1.2.3`
3. Use `--force-reinstall` in Dockerfile if needed

### Image Too Large

```bash
# Check image size
docker images | grep custom-odoo

# Reduce size:
# 1. Remove unnecessary packages
# 2. Use multi-stage builds
# 3. Clean apt cache (already done)
```

## 📚 File Structure

```
odoo/
├── Dockerfile.custom       # Custom image definition
├── requirements.txt        # Python dependencies
├── build-custom-image.sh   # Build script
├── 00-namespace.yaml       # Kubernetes namespace
├── 01-configmap.yaml       # Odoo configuration
├── 02-deployment.yaml      # Kubernetes deployment
├── 03-service.yaml         # Kubernetes service
├── 04-ingress.yaml         # Traefik ingress
└── README.md               # This file
```

## 🎯 Best Practices

1. **Version Pin**: Always pin library versions in `requirements.txt`
2. **Test Locally**: Build and test image locally before deploying
3. **Use Registry**: Push to a registry for production
4. **Tag Properly**: Use semantic versioning (e.g., `custom-odoo:19.0-v1.2.3`)
5. **Document Changes**: Update this README when adding dependencies
6. **Security**: Regularly update base image and dependencies

## 🔗 Related Documentation

- [Main README](../README.md) - Complete project documentation
- [Odoo Performance](./odoo/README.md) - Performance tuning guide
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

---

**Custom Odoo Image for Kubernetes**
© 2025 Dustin Mimbela
