#!/bin/bash
set -e

# Config
DB_NAME="cubica"

echo "🔍 [AUTO-INIT] Checking database '$DB_NAME'..."

# Verificar si la BD existe (usando psql sin contraseña si .pgpass o trust funciona, o aprovechando las vars de entorno PGPASSWORD que Odoo usa)
# El contenedor de Odoo tiene PGPASSWORD=odoo seteo en vars? Si.
export PGPASSWORD=$PASSWORD

if psql -h $HOST -U $USER -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='$DB_NAME'" | grep -q 1; then
    echo "✅ [AUTO-INIT] Database '$DB_NAME' already exists. Starting Odoo..."
else
    echo "⚠️ [AUTO-INIT] Database not found. STARTING AUTOMATIC CREATION..."
    echo "⏳ This process runs in background and avoids HTTP timeouts. Please wait..."
    
    # Crear e inicializar (esto no tiene timeout HTTP)
    odoo -d $DB_NAME -i base --stop-after-init --no-database-list --max-cron-threads=0
    
    echo "✅ [AUTO-INIT] Creation completed successfully."
fi

# Arrancar Odoo normal
echo "🚀 Starting Odoo Server..."
exec odoo -c /var/lib/odoo/odoo.conf
