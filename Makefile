# ============================================
# Odoo on Kubernetes - Makefile
# ============================================
# Professional build and deployment automation

.PHONY: help deploy delete restart status logs shell build push

# Default target
.DEFAULT_GOAL := help

# Variables
NAMESPACE ?= odoo
VERSION ?= 19.0
REGISTRY ?= docker.io/youruser

# Colors
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m

##@ General

help: ## Display this help message
	@awk 'BEGIN {FS = ":.*##"; printf "\n$(BLUE)Usage:$(NC)\n  make $(GREEN)<target>$(NC)\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2 } /^##@/ { printf "\n$(YELLOW)%s$(NC)\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

version: ## Show version information
	@echo "Odoo Kubernetes Stack v1.0.0"
	@echo "Odoo Version: $(VERSION)"

##@ Deployment

deploy: ## Deploy Odoo stack to Kubernetes
	@echo "$(BLUE)🚀 Deploying Odoo stack...$(NC)"
	@./scripts/deploy-all.sh

delete: ## Delete Odoo deployment
	@echo "$(YELLOW)⚠️  Deleting Odoo deployment...$(NC)"
	@./scripts/delete-all.sh

restart: ## Restart Odoo pods
	@echo "$(BLUE)🔄 Restarting Odoo...$(NC)"
	@./scripts/odoo-restart.sh

scale: ## Scale Odoo deployment (usage: make scale REPLICAS=3)
	@echo "$(BLUE)📊 Scaling Odoo to $(REPLICAS) replicas...$(NC)"
	@kubectl scale deployment odoo -n $(NAMESPACE) --replicas=$(REPLICAS)

##@ Monitoring

status: ## Show Odoo status
	@./scripts/odoo-status.sh

logs: ## View Odoo logs
	@./scripts/odoo-logs.sh

logs-follow: ## Follow Odoo logs
	@./scripts/odoo-logs.sh --follow

top: ## Show resource usage
	@kubectl top pods -n $(NAMESPACE)

##@ Development

shell: ## Access Odoo pod shell
	@./scripts/odoo-shell.sh

port-forward: ## Forward Odoo port to localhost:8069
	@echo "$(BLUE)🔌 Forwarding port 8069...$(NC)"
	@echo "Access Odoo at: http://localhost:8069"
	@kubectl port-forward -n $(NAMESPACE) svc/odoo 8069:8069

##@ Docker

build: ## Build custom Docker image (usage: make build VERSION=19.0)
	@echo "$(BLUE)🐳 Building custom Odoo image...$(NC)"
	@cd odoo && ./build-custom-image.sh $(VERSION)

push: ## Push Docker image to registry (usage: make push REGISTRY=yourregistry.com)
	@echo "$(BLUE)📤 Pushing image to $(REGISTRY)...$(NC)"
	@docker tag custom-odoo:$(VERSION) $(REGISTRY)/custom-odoo:$(VERSION)
	@docker push $(REGISTRY)/custom-odoo:$(VERSION)

##@ Database

backup: ## Create database backup
	@./scripts/backup-now.sh

restore: ## Restore from backup (usage: make restore BACKUP=file.tar.gz)
	@./scripts/restore-backup.sh $(BACKUP)

list-backups: ## List available backups
	@./scripts/list-backups.sh

##@ Configuration

config-view: ## View current configuration
	@kubectl get configmap odoo-config -n $(NAMESPACE) -o yaml

config-edit: ## Edit configuration
	@kubectl edit configmap odoo-config -n $(NAMESPACE)

config-reload: ## Reload configuration
	@./reload-config.sh

##@ Cleanup

clean: ## Clean up local resources
	@echo "$(YELLOW)🧹 Cleaning up...$(NC)"
	@docker system prune -f

clean-all: ## Clean up everything (including volumes)
	@echo "$(RED)⚠️  This will delete all data!$(NC)"
	@read -p "Are you sure? (yes/no): " confirm && [ "$$confirm" = "yes" ] || exit 1
	@./scripts/delete-all.sh
	@docker system prune -af --volumes
