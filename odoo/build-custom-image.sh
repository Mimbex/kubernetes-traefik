#!/bin/bash

# ============================================
# Build Custom Odoo Docker Image
# ============================================
# This script builds a custom Odoo Docker image
# with all your custom dependencies.
#
# Usage:
#   ./build-custom-image.sh [VERSION]
#
# Examples:
#   ./build-custom-image.sh 19.0
#   ./build-custom-image.sh 18.0
#   ./build-custom-image.sh 17.0
#   ./build-custom-image.sh 16.0

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🐳 Odoo Custom Image Builder${NC}"
echo "======================================"
echo ""

# Get Odoo version from argument or .env file
if [ -n "$1" ]; then
    ODOO_VERSION=$1
else
    # Try to read from .env file
    if [ -f "../.env" ]; then
        ODOO_VERSION=$(grep ODOO_VERSION ../.env | cut -d'=' -f2)
    else
        ODOO_VERSION="19.0"
    fi
fi

echo -e "${YELLOW}📦 Building Odoo ${ODOO_VERSION} custom image...${NC}"
echo ""

# Docker image name
IMAGE_NAME="custom-odoo"
IMAGE_TAG="${ODOO_VERSION}"
FULL_IMAGE_NAME="${IMAGE_NAME}:${IMAGE_TAG}"

# Build the image
echo -e "${YELLOW}🔨 Building Docker image: ${FULL_IMAGE_NAME}${NC}"
docker build \
    --build-arg ODOO_VERSION=${ODOO_VERSION} \
    -t ${FULL_IMAGE_NAME} \
    -f Dockerfile.custom \
    .

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Image built successfully!${NC}"
    echo ""
    echo "Image name: ${FULL_IMAGE_NAME}"
    echo ""
    echo -e "${YELLOW}📋 Next steps:${NC}"
    echo "1. Update your deployment to use this image"
    echo "2. Or push to a registry:"
    echo "   docker tag ${FULL_IMAGE_NAME} your-registry/${FULL_IMAGE_NAME}"
    echo "   docker push your-registry/${FULL_IMAGE_NAME}"
    echo ""
    echo -e "${YELLOW}🔍 Image details:${NC}"
    docker images | grep ${IMAGE_NAME}
else
    echo ""
    echo -e "${RED}❌ Build failed!${NC}"
    exit 1
fi
