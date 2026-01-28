#!/bin/bash

# ============================================
# Odoo Logs Viewer
# ============================================
# Easy way to view Odoo logs with filtering

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}📋 Odoo Logs Viewer${NC}"
echo "======================================"
echo ""

# Parse arguments
FOLLOW=false
FILTER=""
LINES=100

while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--follow)
            FOLLOW=true
            shift
            ;;
        -n|--lines)
            LINES="$2"
            shift 2
            ;;
        -g|--grep)
            FILTER="$2"
            shift 2
            ;;
        -h|--help)
            echo -e "${YELLOW}Usage:${NC}"
            echo "  $0 [options]"
            echo ""
            echo -e "${YELLOW}Options:${NC}"
            echo "  -f, --follow          Follow logs in real-time"
            echo "  -n, --lines N         Show last N lines (default: 100)"
            echo "  -g, --grep PATTERN    Filter logs by pattern"
            echo "  -h, --help            Show this help"
            echo ""
            echo -e "${YELLOW}Examples:${NC}"
            echo "  $0                              # Show last 100 lines"
            echo "  $0 -f                           # Follow logs"
            echo "  $0 -n 500                       # Show last 500 lines"
            echo "  $0 -g ERROR                     # Show only ERROR lines"
            echo "  $0 -f -g \"my_module\"            # Follow logs for my_module"
            echo ""
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

# Build kubectl command
CMD="kubectl logs -n odoo -l app=odoo"

if [ "$FOLLOW" = true ]; then
    CMD="$CMD -f"
else
    CMD="$CMD --tail=$LINES"
fi

# Show what we're doing
if [ "$FOLLOW" = true ]; then
    echo -e "${YELLOW}📡 Following Odoo logs...${NC}"
else
    echo -e "${YELLOW}📋 Showing last $LINES lines...${NC}"
fi

if [ -n "$FILTER" ]; then
    echo -e "${YELLOW}🔍 Filtering by: $FILTER${NC}"
fi

echo ""
echo -e "${BLUE}Press Ctrl+C to stop${NC}"
echo "======================================"
echo ""

# Execute command
if [ -n "$FILTER" ]; then
    eval $CMD | grep --color=auto "$FILTER"
else
    eval $CMD
fi
