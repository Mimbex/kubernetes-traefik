#!/bin/bash
# Script to install standard OCA repositories
# Usage: ./install_oca.sh

TARGET_DIR="/opt/oca-addons"
VERSION="16.0" # Version mas estable de OCA por ahora, cambiar a 17.0/18.0 segun disponibilidad

echo "📦 Instalando repositorios OCA en $TARGET_DIR..."
mkdir -p $TARGET_DIR

# Lista de repositorios esenciales
REPOS=(
    "https://github.com/OCA/web.git"
    "https://github.com/OCA/server-tools.git"
    "https://github.com/OCA/reporting-engine.git"
    "https://github.com/OCA/account-financial-reporting.git"
    "https://github.com/OCA/social.git"
    "https://github.com/OCA/partner-contact.git"
    "https://github.com/OCA/product-attribute.git"
)

cd $TARGET_DIR

for repo in "${REPOS[@]}"; do
    dir_name=$(basename "$repo" .git)
    if [ -d "$dir_name" ]; then
        echo "✅ $dir_name ya existe. Actualizando..."
        cd $dir_name
        git pull
        cd ..
    else
        echo "⬇️  Clonando $dir_name..."
        git clone -b $VERSION $repo --depth 1 || git clone $repo --depth 1 # Fallback to default branch if version not found
    fi
done

echo "✨ Repositorios OCA listos. Recuerda reiniciar Odoo para cargar los nuevos paths."
echo "   Uso: ./odooctl restart"
