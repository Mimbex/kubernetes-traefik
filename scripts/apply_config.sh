#!/bin/bash
set -a
source .env
set +a

# Validar variables críticas
if [ -z "$HOST" ]; then
    echo "❌ Error: Variable HOST no definida en .env"
    exit 1
fi

echo "⚙️  Procesando configuración de Odoo..."

# Sustituir variables en odoo.conf
# OJO: Solo sustituimos las variables que queremos (HOST, PORT, USER, PASSWORD)
# Si envsubst no recibe argumentos, sustituye TODAS.
# Mejor definimos cuáles exportar.
export HOST PORT USER PASSWORD

envsubst < odoo/odoo.conf > odoo/odoo.conf.tmp

if [ ! -s odoo/odoo.conf.tmp ]; then
    echo "❌ Error: odoo.conf.tmp está vacío tras envsubst"
    rm odoo/odoo.conf.tmp
    exit 1
fi

echo "📤 Subiendo ConfigMap a Kubernetes..."
# Crear ConfigMap con ambos archivos:
# 1. odoo.conf (PROCESADO)
# 2. init_db.sh (CRUDO, ya que es user script y usa variables $ dentro)
kubectl create configmap odoo-config \
    --from-file=odoo.conf=odoo/odoo.conf.tmp \
    --from-file=init_db.sh=odoo/init_db.sh \
    -n odoo --dry-run=client -o yaml | kubectl apply -f -

# Limpieza
rm odoo/odoo.conf.tmp

echo "✅ Configuración aplicada correctamente."
echo "   Usa './odooctl logs -f' para verificar el arranque."
