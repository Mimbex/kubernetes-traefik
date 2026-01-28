#!/bin/bash

# ============================================
# Odoo Status Checker
# ============================================
# Check the status of all Odoo components

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}📊 Odoo Status Dashboard${NC}"
echo "======================================"
echo ""

# Function to check if a resource exists and is ready
check_status() {
    local resource=$1
    local namespace=$2
    local name=$3
    
    if kubectl get $resource $name -n $namespace &> /dev/null; then
        echo -e "${GREEN}✅${NC} $resource/$name"
        return 0
    else
        echo -e "${RED}❌${NC} $resource/$name (not found)"
        return 1
    fi
}

# Check Namespaces
echo -e "${YELLOW}📦 Namespaces:${NC}"
check_status namespace "" odoo
check_status namespace "" postgresql
check_status namespace "" traefik
echo ""

# Check Deployments
echo -e "${YELLOW}🚀 Deployments:${NC}"
check_status deployment odoo odoo
echo ""

# Check StatefulSets
echo -e "${YELLOW}💾 StatefulSets:${NC}"
check_status statefulset postgresql postgresql
echo ""

# Check Services
echo -e "${YELLOW}🌐 Services:${NC}"
check_status service odoo odoo
check_status service postgresql postgresql
check_status service traefik traefik
echo ""

# Check Ingress
echo -e "${YELLOW}🔀 Ingress:${NC}"
check_status ingress odoo odoo-ingress
echo ""

# Check Pods
echo -e "${YELLOW}📦 Pods Status:${NC}"
echo ""
echo "Odoo:"
kubectl get pods -n odoo -l app=odoo 2>/dev/null || echo -e "${RED}  No pods found${NC}"
echo ""
echo "PostgreSQL:"
kubectl get pods -n postgresql -l app=postgresql 2>/dev/null || echo -e "${RED}  No pods found${NC}"
echo ""
echo "Traefik:"
kubectl get pods -n traefik -l app.kubernetes.io/name=traefik 2>/dev/null || echo -e "${RED}  No pods found${NC}"
echo ""

# Check PVCs
echo -e "${YELLOW}💿 Persistent Volume Claims:${NC}"
kubectl get pvc -n odoo 2>/dev/null || echo -e "${RED}  No PVCs found${NC}"
echo ""

# Check Odoo URL
echo -e "${YELLOW}🌍 Access Information:${NC}"
DOMAIN=$(kubectl get ingress odoo-ingress -n odoo -o jsonpath='{.spec.rules[0].host}' 2>/dev/null)
if [ -n "$DOMAIN" ]; then
    echo -e "  Odoo URL: ${GREEN}https://$DOMAIN${NC}"
else
    echo -e "  ${RED}Ingress not configured${NC}"
fi
echo ""

# Check Longpolling
echo -e "${YELLOW}🔌 Longpolling Status:${NC}"
POD_NAME=$(kubectl get pod -n odoo -l app=odoo -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -n "$POD_NAME" ]; then
    GEVENT_CHECK=$(kubectl logs -n odoo $POD_NAME 2>/dev/null | grep -i "longpolling" | tail -1)
    if [ -n "$GEVENT_CHECK" ]; then
        echo -e "  ${GREEN}✅ Longpolling enabled${NC}"
        echo "  $GEVENT_CHECK"
    else
        echo -e "  ${YELLOW}⚠️  Longpolling status unknown (check logs)${NC}"
    fi
else
    echo -e "  ${RED}❌ No Odoo pod running${NC}"
fi
echo ""

# Resource Usage
echo -e "${YELLOW}📈 Resource Usage:${NC}"
kubectl top pods -n odoo 2>/dev/null || echo -e "${RED}  Metrics not available (install metrics-server)${NC}"
echo ""

echo "======================================"
echo -e "${BLUE}💡 Quick Commands:${NC}"
echo "  ./scripts/odoo-logs.sh -f         # View logs"
echo "  ./scripts/odoo-restart.sh         # Restart Odoo"
echo "  ./scripts/odoo-shell.sh           # Access pod shell"
echo ""
