# Configuration Guide

## Environment Variables

All configuration is centralized in the `.env` file. This avoids editing multiple YAML files.

### Setup

1. Copy the example file:
```bash
cp .env.example .env
```

2. Edit with your values:
```bash
nano .env
```

### Available Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `ODOO_DOMAIN` | Your Odoo domain | `odoo.example.com` |
| `TRAEFIK_DOMAIN` | Traefik dashboard domain (optional) | `traefik.example.com` |
| `LETSENCRYPT_EMAIL` | Email for Let's Encrypt notifications | `admin@example.com` |
| `POSTGRES_USER` | PostgreSQL username | `odoo` |
| `POSTGRES_PASSWORD` | PostgreSQL password | `secure-password` |
| `POSTGRES_DB` | PostgreSQL database name | `postgres` |
| `ODOO_ADMIN_PASSWORD` | Odoo master password | `admin-password` |

### How It Works

The deployment script (`scripts/deploy-all.sh`) uses `envsubst` to replace variables in YAML files before applying them to Kubernetes.

Files with variables:
- `traefik/02-deployment.yaml` - Uses `${LETSENCRYPT_EMAIL}`
- `odoo/04-ingress.yaml` - Uses `${ODOO_DOMAIN}`

### Security Notes

⚠️ **Important:**
- Never commit `.env` to Git (it's in `.gitignore`)
- Use strong passwords in production
- Change default values from `.env.example`
- Keep `.env` file permissions restricted: `chmod 600 .env`

### Example Production Configuration

```env
# Production example
ODOO_DOMAIN=erp.mycompany.com
LETSENCRYPT_EMAIL=it@mycompany.com
POSTGRES_USER=odoo_prod
POSTGRES_PASSWORD=Xk9#mP2$vL8@qR5
POSTGRES_DB=production
ODOO_ADMIN_PASSWORD=Zt7&nQ4!wE3@hY6
```

## Manual Configuration (Advanced)

If you prefer to edit YAML files directly instead of using `.env`:

1. Edit `odoo/04-ingress.yaml`:
   - Replace `${ODOO_DOMAIN}` with your actual domain

2. Edit `traefik/02-deployment.yaml`:
   - Replace `${LETSENCRYPT_EMAIL}` with your email

3. Modify `scripts/deploy-all.sh`:
   - Remove the `envsubst` commands
   - Use regular `kubectl apply -f` instead

## Updating Configuration

To update configuration after deployment:

```bash
# Edit .env
nano .env

# Redeploy affected services
./scripts/deploy-all.sh
```

Or update specific components:

```bash
# Update Odoo ingress only
export $(cat .env | grep -v '^#' | xargs)
envsubst < odoo/04-ingress.yaml | kubectl apply -f -
```

## Multiple Environments

You can maintain different configurations:

```bash
# Development
cp .env.example .env.dev
# Edit .env.dev

# Production  
cp .env.example .env.prod
# Edit .env.prod

# Deploy with specific env
cp .env.prod .env
./scripts/deploy-all.sh
```

---

For more information, see [README.md](README.md)
