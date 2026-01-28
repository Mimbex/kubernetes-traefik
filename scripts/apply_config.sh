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

# Procesar odoo.conf con envsubst y crear ConfigMap
# Creamos un archivo temporal procesado
envsubst < odoo/odoo.conf > odoo/odoo.conf.tmp

# Verificamos que no quedó vacío
if [ ! -s odoo/odoo.conf.tmp ]; then
    echo "❌ Error: El archivo de configuración procesado está vacío. Revisa tus variables."
    rm odoo/odoo.conf.tmp
    exit 1
fi

echo "📤 Subiendo ConfigMap a Kubernetes..."
# Creamos/Actualizamos el ConfigMap usando el archivo procesado
# Usamos --from-file=odoo.conf=... para que la clave sea 'odoo.conf'
kubectl create configmap odoo-config -n odoo --from-file=odoo.conf=odoo/odoo.conf.tmp --dry-run=client -o yaml | kubectl apply -f -

# Limpieza
rm odoo/odoo.conf.tmp

echo "🔄 Reiniciando Odoo para aplicar cambios..."
kubectl rollout restart deployment odoo -n odoo

echo "✅ Configuración aplicada correctamente."
echo "   Usa './odooctl logs -f' para verificar el arranque."
