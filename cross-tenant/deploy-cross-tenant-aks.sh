#!/bin/bash
# Generated by Copilot
# Script para deploy do AKS com Cross-Tenant RBAC

set -euo pipefail

# Configurações
PRINCIPAL_TENANT_ID="83d6df9e-eec5-4d37-be60-97bf712d85ab"
RESOURCE_GROUP="rg-shipping-dronedelivery-eastus2"  # Resource group atual
DEPLOYMENT_NAME="aks-cross-tenant-$(date +%Y%m%d-%H%M%S)"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

echo "======================================================="
echo "  DEPLOY AKS COM CROSS-TENANT RBAC"
echo "======================================================="
echo ""
echo "Tenant Principal: $PRINCIPAL_TENANT_ID"
echo "Resource Group: $RESOURCE_GROUP"
echo "Deployment: $DEPLOYMENT_NAME"
echo ""

# Login no tenant principal
log "Fazendo login no tenant principal..."
az login --tenant $PRINCIPAL_TENANT_ID

# Selecionar subscription
log "Selecionando subscription..."
SUBSCRIPTION_ID=$(az account list --query "[?tenantId=='$PRINCIPAL_TENANT_ID'].id" -o tsv | head -1)
if [[ -z "$SUBSCRIPTION_ID" ]]; then
    error "Nenhuma subscription encontrada no tenant principal"
    exit 1
fi

az account set --subscription "$SUBSCRIPTION_ID"
success "Subscription selecionada: $SUBSCRIPTION_ID"

# Verificar se resource group existe
if ! az group show --name "$RESOURCE_GROUP" &>/dev/null; then
    error "Resource Group '$RESOURCE_GROUP' não encontrado"
    echo "Resource Groups disponíveis:"
    az group list --query "[].name" -o table
    exit 1
fi

# Deploy do template
log "Iniciando deployment..."
az deployment group create \
  --resource-group "$RESOURCE_GROUP" \
  --template-file cluster-stamp.bicep \
  --parameters @azuredeploy.parameters.cross-tenant.json \
  --name "$DEPLOYMENT_NAME" \
  --verbose

success "Deployment concluído: $DEPLOYMENT_NAME"

echo ""
echo "======================================================="
echo "  PRÓXIMOS PASSOS"
echo "======================================================="
echo "1. Obter credenciais do cluster:"
echo "   az aks get-credentials --resource-group $RESOURCE_GROUP --name <CLUSTER_NAME> --overwrite-existing"
echo ""
echo "2. Testar acesso com usuário do Entra ID External:"
echo "   kubectl get nodes"
echo "   kubectl auth whoami"
echo ""
echo "3. Para usuários do Entra ID External, login deve ser:"
echo "   az login --tenant cdbba3b9-3344-40cd-9f2d-5a463efc272d"
echo ""
