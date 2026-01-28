#!/bin/bash
# Script para aplicar cambios en odoo/odoo.conf al cluster
# Uso: ./scripts/apply_config.sh

echo "⚙️  Procesando configuración de Odoo..."

# Verificar .env
if [ ! -f .env ]; then
    echo "❌ Error: Archivo .env no encontrado."
    exit 1
fi

# Cargar variables para sustitución
set -a
source .env
set +a

# Procesar odoo.conf con envsubst (limitado a variables conocidas para no romper hashes)
export VARS='$POSTGRES_USER $POSTGRES_PASSWORD'
envsubst "$VARS" < odoo/odoo.conf > odoo/odoo.conf.tmp

# Verificamos que no quedó vacío
if [ ! -s odoo/odoo.conf.tmp ]; then
    echo "❌ Error: El archivo de configuración procesado está vacío. Revisa tus variables."
    rm odoo/odoo.conf.tmp
    exit 1
fi

echo "📤 Subiendo ConfigMap a Kubernetes..."
# Crear ConfigMap con ambios archivos
kubectl create configmap odoo-config \
    --from-file=odoo.conf=odoo/odoo.conf \
    --from-file=init_db.sh=odoo/init_db.sh \
    -n odoo --dry-run=client -o yaml | kubectl apply -f -

# Limpieza
rm odoo/odoo.conf.tmp

echo "🔄 Reiniciando Odoo para aplicar cambios..."
kubectl rollout restart deployment odoo -n odoo

echo "✅ Configuración aplicada correctamente."
echo "   Usa './odooctl logs -f' para verificar el arranque."
