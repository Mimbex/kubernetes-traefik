#!/bin/bash

# ============================================
# Odoo Quick Restart Script
# ============================================
# Quickly restart Odoo pods to apply changes
# (new modules, configuration updates, etc.)

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔄 Odoo Quick Restart${NC}"
echo "======================================"
echo ""

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl not found. Please install kubectl first.${NC}"
    exit 1
fi

# Check if Odoo deployment exists
if ! kubectl get deployment odoo -n odoo &> /dev/null; then
    echo -e "${RED}❌ Odoo deployment not found in namespace 'odoo'${NC}"
    exit 1
fi

echo -e "${YELLOW}📊 Current Odoo pods:${NC}"
kubectl get pods -n odoo -l app=odoo
echo ""

echo -e "${YELLOW}🔄 Restarting Odoo deployment...${NC}"
kubectl rollout restart deployment odoo -n odoo

echo ""
echo -e "${YELLOW}⏳ Waiting for rollout to complete...${NC}"
kubectl rollout status deployment odoo -n odoo --timeout=5m

echo ""
echo -e "${GREEN}✅ Odoo restarted successfully!${NC}"
echo ""

echo -e "${YELLOW}📊 New pods:${NC}"
kubectl get pods -n odoo -l app=odoo
echo ""

echo -e "${BLUE}💡 Tips:${NC}"
echo "  - Wait 1-2 minutes for Odoo to fully start"
echo "  - Check logs: kubectl logs -n odoo -l app=odoo -f"
echo "  - Update apps list in Odoo: Apps → Update Apps List"
echo ""
