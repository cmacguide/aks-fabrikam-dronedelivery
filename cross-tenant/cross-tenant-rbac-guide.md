# Configuração Entra ID External para RBAC do AKS

## Cenário: Cross-Tenant RBAC com Entra ID External

### Arquitetura Proposta

- **Tenant Principal (83d6df9e-eec5-4d37-be60-97bf712d85ab)**: Onde estão os recursos do AKS
- **Tenant Entra ID External (cdbba3b9-3344-40cd-9f2d-5a463efc272d)**: Onde estão os usuários e grupos para RBAC

Esta configuração é **totalmente suportada** e representa uma prática recomendada para separar gestão de identidades dos recursos.

## Benefícios desta Abordagem

1. **Separação de Responsabilidades**: Identidades separadas dos recursos
2. **Gestão Centralizada**: Usuários externos em tenant dedicado
3. **Segurança Aprimorada**: Isolamento entre ambientes
4. **Flexibilidade**: Facilita gestão de usuários temporários/externos

## Configuração Passo a Passo

### Passo 1: Configurar Grupo no Tenant Entra ID External

No tenant `cdbba3b9-3344-40cd-9f2d-5a463efc272d`:

```bash
# Login no tenant Entra ID External
az login --tenant cdbba3b9-3344-40cd-9f2d-5a463efc272d --allow-no-subscriptions

# Criar grupo para administradores AKS
az ad group create \
  --display-name "AKS-Fabrikam-Administrators" \
  --mail-nickname "aks-fabrikam-admins" \
  --description "Administradores do cluster AKS Fabrikam"

# Obter o Object ID do grupo (necessário para configuração)
GROUP_ID=$(az ad group show --group "AKS-Fabrikam-Administrators" --query id -o tsv)
echo "Group Object ID: $GROUP_ID"

# Adicionar usuários ao grupo
az ad group member add --group "$GROUP_ID" --member-id <USER_OBJECT_ID>
```

### Passo 2: Configurar AKS no Tenant Principal

No tenant `83d6df9e-eec5-4d37-be60-97bf712d85ab`:

```bash
# Login no tenant principal (onde estão os recursos)
az login --tenant 83d6df9e-eec5-4d37-be60-97bf712d85ab

# Atualizar cluster AKS para usar Entra ID External
az aks update \
  --resource-group <RESOURCE_GROUP> \
  --name <AKS_CLUSTER_NAME> \
  --aad-admin-group-object-ids $GROUP_ID \
  --aad-tenant-id cdbba3b9-3344-40cd-9f2d-5a463efc272d
```

### Passo 3: Atualizar Template Bicep

Atualizar o arquivo `cluster-stamp.bicep`:

```bicep
// Configuração para Cross-Tenant RBAC
param k8sRbacEntraAdminGroupObjectID string
param k8sRbacEntraProfileTenantId string = 'cdbba3b9-3344-40cd-9f2d-5a463efc272d'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2023-08-01' = {
  // ...existing configuration...
  properties: {
    // ...existing properties...
    aadProfile: {
      managed: true
      enableAzureRBAC: false  // Usar K8s RBAC nativo
      adminGroupObjectIDs: [
        k8sRbacEntraAdminGroupObjectID
      ]
      tenantID: k8sRbacEntraProfileTenantId  // Tenant Entra ID External
    }
  }
}
```

### Passo 4: Atualizar Parâmetros de Deployment

Atualizar `azuredeploy.parameters.prod.json`:

```json
{
  "k8sRbacEntraAdminGroupObjectID": {
    "value": "[NOVO_GROUP_ID_DO_TENANT_EXTERNAL]"
  },
  "k8sRbacEntraProfileTenantId": {
    "value": "cdbba3b9-3344-40cd-9f2d-5a463efc272d"
  }
}
```

## Processo de Autenticação

### Para Usuários do Entra ID External

1. **Login Inicial**:

```bash
# Login especificando o tenant Entra ID External
az login --tenant cdbba3b9-3344-40cd-9f2d-5a463efc272d
```

2. **Obter Credenciais AKS**:

```bash
# Mudar para o tenant principal para acessar recursos
az account set --subscription <SUBSCRIPTION_ID_TENANT_PRINCIPAL>

# Obter credenciais do cluster
az aks get-credentials \
  --resource-group <RESOURCE_GROUP> \
  --name <AKS_CLUSTER_NAME> \
  --overwrite-existing
```

3. **Validar Acesso**:

```bash
# Teste básico
kubectl get nodes

# Verificar identidade
kubectl auth whoami
```

## Melhores Práticas para Cross-Tenant RBAC

### 1. Gestão de Grupos

- Criar grupos específicos por função (admin, developer, viewer)
- Usar nomenclatura clara (ex: AKS-ProjectName-Role)
- Documentar propósito de cada grupo

### 2. Princípio de Menor Privilégio

```yaml
# Exemplo: Role para desenvolvedores
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: aks-developer-role
rules:
  - apiGroups: [""]
    resources: ["pods", "services", "endpoints"]
    verbs: ["get", "list", "watch"]
  - apiGroups: ["apps"]
    resources: ["deployments", "replicasets"]
    verbs: ["get", "list", "watch", "create", "update", "patch"]
```

### 3. Monitoramento e Auditoria

- Habilitar logs de auditoria do AKS
- Monitorar acessos cross-tenant
- Revisar permissões regularmente

## Troubleshooting Comum

### Problema: "Invalid tenant"

**Solução**: Verificar se o usuário tem acesso ao tenant Entra ID External

### Problema: "Insufficient privileges"

**Solução**: Verificar se o usuário está no grupo correto e se o grupo tem as permissões adequadas

### Problema: "Cannot get nodes"

**Solução**: Verificar configuração do aadProfile no AKS

## Comandos Úteis para Diagnóstico

```bash
# Verificar configuração atual do AKS
az aks show --resource-group <RG> --name <CLUSTER> --query "aadProfile"

# Listar grupos do usuário atual
az ad user get-member-groups --id <USER_ID>

# Verificar permissões no Kubernetes
kubectl auth can-i --list
```

## Validação Final

1. ✅ Grupo criado no tenant Entra ID External
2. ✅ AKS configurado para usar tenant Entra ID External
3. ✅ Usuários adicionados ao grupo
4. ✅ RBAC funcionando corretamente
5. ✅ Monitoramento configurado

<!-- Generated by Copilot -->
