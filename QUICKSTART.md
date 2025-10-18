# Quick Start Guide

## 1. Prerequisites

```bash
# Check kubectl is installed
kubectl version --client

# Check cluster connection
kubectl cluster-info
```

## 2. Configure Environment Variables

Copy and edit the `.env` file:

```bash
cp .env.example .env
nano .env
```

Set your values:

```env
ODOO_DOMAIN=odoo.yourdomain.com
LETSENCRYPT_EMAIL=your-email@example.com
POSTGRES_PASSWORD=your-secure-password
ODOO_ADMIN_PASSWORD=your-admin-password
```

## 3. Deploy

```bash
./scripts/deploy-all.sh
```

The script will show your configured domain at the end.

## 4. Get LoadBalancer IP

```bash
kubectl get svc traefik -n traefik
```

## 5. Configure DNS

Point your domain to the EXTERNAL-IP:

```
A Record: your-odoo-domain -> EXTERNAL-IP
```

## 6. Access Odoo

Wait 2-3 minutes for SSL certificate generation, then access your configured domain.

## Common Commands

```bash
# Check status
kubectl get pods --all-namespaces

# View logs
kubectl logs -n odoo -l app=odoo -f

# Scale Odoo
kubectl scale deployment odoo -n odoo --replicas=3

# Delete everything
./scripts/delete-all.sh
```

## Troubleshooting

### Pods not starting

```bash
kubectl describe pod <pod-name> -n <namespace>
```

### Check ingress

```bash
kubectl get ingress -n odoo
kubectl describe ingress odoo-ingress -n odoo
```

### SSL not working

```bash
kubectl logs -n traefik -l app=traefik | grep acme
```

---

For full documentation, see [README.md](README.md)
