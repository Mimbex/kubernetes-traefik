#!/bin/bash

# ============================================
# Install Odoo Module Script
# ============================================
# Easy script to add custom modules and restart Odoo

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}📦 Odoo Module Installer${NC}"
echo "======================================"
echo ""

# Check arguments
if [ $# -eq 0 ]; then
    echo -e "${YELLOW}Usage:${NC}"
    echo "  $0 <module-path>              # Install from local directory"
    echo "  $0 <git-url> [branch]         # Install from Git repository"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo "  $0 /path/to/my_module"
    echo "  $0 https://github.com/user/odoo-module.git"
    echo "  $0 https://github.com/OCA/server-tools.git 16.0"
    echo ""
    exit 1
fi

MODULE_SOURCE=$1
BRANCH=${2:-"main"}

# Get Odoo pod name
POD_NAME=$(kubectl get pod -n odoo -l app=odoo -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -z "$POD_NAME" ]; then
    echo -e "${RED}❌ No Odoo pod found. Is Odoo running?${NC}"
    exit 1
fi

echo -e "${YELLOW}📍 Using pod: ${POD_NAME}${NC}"
echo ""

# Check if it's a Git URL or local path
if [[ $MODULE_SOURCE == http* ]] || [[ $MODULE_SOURCE == git@* ]]; then
    # Git repository
    echo -e "${YELLOW}📥 Cloning from Git repository...${NC}"
    echo "  URL: $MODULE_SOURCE"
    echo "  Branch: $BRANCH"
    echo ""
    
    # Clone inside the pod
    kubectl exec -n odoo $POD_NAME -- bash -c "
        cd /mnt/extra-addons && \
        git clone -b $BRANCH $MODULE_SOURCE
    "
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Module cloned successfully${NC}"
    else
        echo -e "${RED}❌ Failed to clone repository${NC}"
        exit 1
    fi
else
    # Local directory
    if [ ! -d "$MODULE_SOURCE" ]; then
        echo -e "${RED}❌ Directory not found: $MODULE_SOURCE${NC}"
        exit 1
    fi
    
    MODULE_NAME=$(basename "$MODULE_SOURCE")
    echo -e "${YELLOW}📤 Copying module: ${MODULE_NAME}${NC}"
    echo ""
    
    # Copy to pod
    kubectl cp "$MODULE_SOURCE" odoo/$POD_NAME:/mnt/extra-addons/$MODULE_NAME
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Module copied successfully${NC}"
    else
        echo -e "${RED}❌ Failed to copy module${NC}"
        exit 1
    fi
fi

echo ""
echo -e "${YELLOW}🔍 Checking module structure...${NC}"
kubectl exec -n odoo $POD_NAME -- ls -la /mnt/extra-addons/

echo ""
echo -e "${YELLOW}🔄 Restarting Odoo to load new module...${NC}"
kubectl rollout restart deployment odoo -n odoo

echo ""
echo -e "${YELLOW}⏳ Waiting for Odoo to restart...${NC}"
kubectl rollout status deployment odoo -n odoo --timeout=5m

echo ""
echo -e "${GREEN}✅ Module installed successfully!${NC}"
echo ""
echo -e "${BLUE}📋 Next steps:${NC}"
echo "  1. Wait 1-2 minutes for Odoo to fully start"
echo "  2. Go to Odoo web interface"
echo "  3. Enable Developer Mode: Settings → Activate Developer Mode"
echo "  4. Go to Apps → Update Apps List"
echo "  5. Search for your module and click Install"
echo ""
echo -e "${YELLOW}💡 Tip: Check logs if module doesn't appear${NC}"
echo "  kubectl logs -n odoo -l app=odoo -f"
echo ""
