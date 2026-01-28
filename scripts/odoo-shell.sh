#!/bin/bash

# ============================================
# Odoo Shell Access
# ============================================
# Quick access to Odoo pod shell

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🐚 Odoo Shell Access${NC}"
echo "======================================"
echo ""

# Get Odoo pod name
POD_NAME=$(kubectl get pod -n odoo -l app=odoo -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -z "$POD_NAME" ]; then
    echo -e "${RED}❌ No Odoo pod found. Is Odoo running?${NC}"
    exit 1
fi

echo -e "${YELLOW}📍 Connecting to pod: ${POD_NAME}${NC}"
echo ""
echo -e "${BLUE}💡 Useful commands inside the pod:${NC}"
echo "  ls /mnt/extra-addons/          # List custom modules"
echo "  cat /etc/odoo/odoo.conf        # View Odoo configuration"
echo "  pip3 list                      # List Python packages"
echo "  odoo --help                    # Odoo command help"
echo ""
echo -e "${YELLOW}Press Ctrl+D or type 'exit' to leave${NC}"
echo "======================================"
echo ""

# Execute shell
kubectl exec -it -n odoo $POD_NAME -- /bin/bash
