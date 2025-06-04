# ✅ CONFIGURAÇÃO CROSS-TENANT RBAC - AMBIENTE ATUAL

## 📋 Status da Configuração

### 🎯 Cenário Implementado

✅ **Cross-Tenant RBAC ATIVO** - O cluster AKS já está configurado e operacional

- **Tenant Principal**: `83d6df9e-eec5-4d37-be60-97bf712d85ab` (Recursos do AKS)
- **Tenant Entra ID External**: `cdbba3b9-3344-40cd-9f2d-5a463efc272d` (Usuários e grupos RBAC)

### 🏗️ Cluster AKS Atual

- **Nome**: `aks-2hptu3pqac3xy`
- **Resource Group**: `rg-shipping-dronedelivery-eastus2`
- **Status**: `Succeeded` ✅
- **Localização**: East US 2
- **Versão Kubernetes**: `1.32.4`
- **Subscription**: `1e57ee4b-1c01-4752-9866-527cf3136b2d`

### 👥 Grupo RBAC Configurado

- **Nome**: `dronedelivery-cluster-admin`
- **Object ID**: `93ae7ed7-8077-4ed4-9947-ca3e991a253f`
- **Tenant**: Entra ID External (`cdbba3b9-3344-40cd-9f2d-5a463efc272d`)

**Membros Atuais:**

- ✅ Cmac JR (`jrcarlosmachado_gmail.com#EXT#@bimoptimize.onmicrosoft.com`)
- ✅ dronedelivery-admin (`dronedelivery-admin@bimoptimize.onmicrosoft.com`)
- ✅ aks.ops (`aks.ops@bimoptimize.onmicrosoft.com`)

## 🔧 Arquivos Atualizados

### 1. Parâmetros de Configuração

```json
// azuredeploy.parameters.cross-tenant.json
{
  "k8sRbacEntraAdminGroupObjectID": {
    "value": "93ae7ed7-8077-4ed4-9947-ca3e991a253f"
  },
  "k8sRbacEntraProfileTenantId": {
    "value": "cdbba3b9-3344-40cd-9f2d-5a463efc272d"
  }
}
```

### 2. Scripts Disponíveis

- ✅ `test-cluster-access.sh` - **NOVO** - Testa acesso ao cluster existente
- ✅ `deploy-cross-tenant-aks.sh` - Script de deploy (atualizado com RG correto)
- ✅ `setup-entra-external-rbac.sh` - Setup do Entra External (atualizado)

### 3. Manifests Kubernetes

```yaml
# cluster-manifests/user-facing-cluster-role-entra-group.yaml
subjects:
  - kind: Group
    name: 93ae7ed7-8077-4ed4-9947-ca3e991a253f # dronedelivery-cluster-admin
```

## 🚀 Como Testar o Acesso

### Opção 1: Script Automatizado (Recomendado)

```bash
# Executar script de teste completo
./cross-tenant/test-cluster-access.sh
```

### Opção 2: Teste Manual

```bash
# 1. Login no tenant Entra ID External
az login --tenant cdbba3b9-3344-40cd-9f2d-5a463efc272d

# 2. Verificar membership no grupo
az ad group member check \
  --group "93ae7ed7-8077-4ed4-9947-ca3e991a253f" \
  --member-id $(az ad signed-in-user show --query id -o tsv)

# 3. Configurar subscription
az account set --subscription 1e57ee4b-1c01-4752-9866-527cf3136b2d

# 4. Obter credenciais do cluster
az aks get-credentials \
  --resource-group rg-shipping-dronedelivery-eastus2 \
  --name aks-2hptu3pqac3xy \
  --overwrite-existing

# 5. Testar acesso
kubectl get nodes
kubectl auth whoami
kubectl get namespaces
```

## 👨‍💼 Adicionando Novos Usuários

### 1. Login no Tenant Entra External

```bash
az login --tenant cdbba3b9-3344-40cd-9f2d-5a463efc272d
```

### 2. Adicionar Usuário ao Grupo

```bash
# Obter Object ID do usuário
USER_ID=$(az ad user show --id "usuario@dominio.com" --query id -o tsv)

# Adicionar ao grupo
az ad group member add \
  --group "93ae7ed7-8077-4ed4-9947-ca3e991a253f" \
  --member-id $USER_ID
```

### 3. Instruções para o Novo Usuário

```bash
# Login no tenant correto
az login --tenant cdbba3b9-3344-40cd-9f2d-5a463efc272d

# Configurar subscription
az account set --subscription 1e57ee4b-1c01-4752-9866-527cf3136b2d

# Obter credenciais do cluster
az aks get-credentials \
  --resource-group rg-shipping-dronedelivery-eastus2 \
  --name aks-2hptu3pqac3xy

# Testar acesso
kubectl get nodes
```

## 🛡️ Configuração de Segurança Implementada

### AAD Profile no AKS

```bicep
aadProfile: {
  managed: true
  adminGroupObjectIDs: [
    "93ae7ed7-8077-4ed4-9947-ca3e991a253f"  // dronedelivery-cluster-admin
  ]
  tenantID: "cdbba3b9-3344-40cd-9f2d-5a463efc272d"  // Entra External
}
```

### RBAC Kubernetes

O grupo possui as seguintes permissões via ClusterRoleBinding:

- **cluster-admin**: Acesso completo ao cluster
- **admin**: Acesso administrativo por namespace
- **edit**: Permissões de edição
- **view**: Permissões de visualização

## 🔍 Validação do Ambiente

### Verificar Status do Cluster

```bash
# Via Azure CLI
az aks show \
  --resource-group rg-shipping-dronedelivery-eastus2 \
  --name aks-2hptu3pqac3xy \
  --query "aadProfile"

# Via kubectl (após obter credenciais)
kubectl cluster-info
kubectl get nodes
kubectl auth whoami
```

### Verificar Grupo no Entra ID External

```bash
# Login no tenant externo
az login --tenant cdbba3b9-3344-40cd-9f2d-5a463efc272d

# Detalhes do grupo
az ad group show --group "93ae7ed7-8077-4ed4-9947-ca3e991a253f"

# Lista de membros
az ad group member list --group "93ae7ed7-8077-4ed4-9947-ca3e991a253f"
```

## 🎉 Próximos Passos

1. **Testar Acesso**: Execute `./cross-tenant/test-cluster-access.sh`
2. **Validar Workloads**: Verificar se aplicações estão funcionando
3. **Documentar Processo**: Criar runbook para equipe
4. **Monitoramento**: Configurar alertas para RBAC

## 📞 Referências

- [AKS AAD Integration](https://learn.microsoft.com/en-us/azure/aks/managed-aad)
- [Cross-tenant RBAC](https://learn.microsoft.com/en-us/azure/role-based-access-control/cross-tenant-rbac)
- [Kubernetes RBAC](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)

<!-- Generated by Copilot -->
