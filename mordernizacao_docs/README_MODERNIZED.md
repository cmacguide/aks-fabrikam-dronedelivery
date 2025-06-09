# 🚀 Fabrikam Drone Delivery - Modernized AKS Deployment ✅ CONCLUÍDO

> **⚡ Modernização Completa**: Este projeto foi modernizado para usar **Azure Developer CLI (azd)** eliminando a necessidade de configuração manual e scripts complexos. Deploy completo em **um único comando**!

> **✅ STATUS**: Modernização finalizada com sucesso! Todos os módulos Bicep criados e validados.

## 📋 Visão Geral

Esta é uma implementação modernizada do [AKS Secure Baseline](https://github.com/mspnp/aks-secure-baseline) com a aplicação Fabrikam Drone Delivery, utilizando Azure Developer CLI (azd) para automação completa do deploy.

### 🎯 **Principais Benefícios da Modernização**

| **ANTES**                           | **DEPOIS**              |
| ----------------------------------- | ----------------------- |
| 40+ comandos manuais                | 1 comando: `azd up`     |
| 11 passos de documentação           | 3 comandos simples      |
| 2-3 horas de setup                  | 30-45 minutos           |
| Alto risco de erro humano           | Deploy automatizado     |
| Configuração específica de ambiente | Templates reutilizáveis |

### 🏗️ **Arquitetura**

![Arquitetura](./imgs/architecture.png)

A solução deploy:

- **🌐 Rede Hub-Spoke** com Azure Firewall e Application Gateway
- **🚢 Cluster AKS** com autoscaling e monitoring
- **🔐 Segurança** com Key Vault, Managed Identities e RBAC
- **📊 Observabilidade** com Application Insights e Container Insights
- **⚙️ GitOps** com Flux para gerenciamento de configurações
- **🔄 CI/CD** pronto para GitHub Actions

### 🎛️ **Microserviços Incluídos**

1. **Delivery Service** (.NET Core) - Gerenciamento de entregas
2. **Ingestion Service** (Node.js) - Ingestão de pedidos
3. **Workflow Service** (Java) - Orquestração de workflows
4. **DroneScheduler Service** (.NET Core) - Agendamento de drones
5. **Package Service** (Node.js) - Gerenciamento de pacotes

---

## 🚀 Quick Start

### **Pré-requisitos**

```bash
# 1. Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# 2. Azure Developer CLI
curl -fsSL https://aka.ms/install-azd.sh | bash

# 3. Ferramentas adicionais (para desenvolvimento)
# kubectl, helm, docker
```

### **Deploy Completo em 3 Comandos**

```bash
# 1. Clone e inicialize
git clone https://github.com/mspnp/aks-fabrikam-dronedelivery.git
cd aks-fabrikam-dronedelivery

# 2. Login no Azure
azd auth login

# 3. Deploy completo (infraestrutura + aplicações)
azd up
```

🎉 **Pronto!** Sua aplicação estará rodando em ~30-45 minutos.

---

## 📖 Comandos Detalhados

### **Gestão de Ambientes**

```bash
# Criar novo ambiente
azd env new production

# Listar ambientes
azd env list

# Alternar entre ambientes
azd env select development

# Ver configurações
azd env show
```

### **Deploy Granular**

```bash
# Deploy apenas infraestrutura
azd provision

# Deploy apenas aplicações
azd deploy

# Deploy específico (depois de mudanças)
azd deploy --service delivery
```

### **Monitoramento e Troubleshooting**

```bash
# Abrir dashboard de monitoramento
azd monitor

# Ver logs das aplicações
azd logs

# Status do deployment
azd show

# Conectar ao cluster AKS
az aks get-credentials --name <cluster-name> --resource-group <rg-name>

# Ver pods em execução
kubectl get pods -A
```

### **Limpeza**

```bash
# Remover recursos (mantém dados)
azd down

# Remover tudo incluindo dados
azd down --force --purge
```

---

## ⚙️ Configuração Avançada

### **Variáveis de Ambiente**

As seguintes variáveis podem ser customizadas:

```bash
# Localização principal
azd env set AZURE_LOCATION "eastus2"

# Ambiente (dev/staging/prod)
azd env set ENVIRONMENT_NAME "dev"

# Domínio da aplicação
azd env set DOMAIN_NAME "mycompany.com"

# Versão do Kubernetes
azd env set KUBERNETES_VERSION "1.29"

# Grupo de admin do AKS (será criado automaticamente se não existir)
azd env set K8S_RBAC_ENTRA_ADMIN_GROUP_OBJECT_ID "12345678-1234-1234-1234-123456789012"
```

### **Ambientes Múltiplos**

```bash
# Desenvolvimento
azd env new development
azd env set ENVIRONMENT_NAME "dev"
azd env set NODE_COUNT "3"
azd env set VM_SIZE "Standard_D4s_v3"

# Produção
azd env new production
azd env set ENVIRONMENT_NAME "prod"
azd env set NODE_COUNT "10"
azd env set VM_SIZE "Standard_D16s_v3"
```

---

## 🎯 Validação e Testes

### **Verificar Deploy**

```bash
# Status dos pods
kubectl get pods -n backend-dev

# Status dos serviços
kubectl get services -n backend-dev

# Logs de um serviço específico
kubectl logs -f deployment/delivery -n backend-dev
```

### **Testar Aplicação**

```bash
# Obter IP público do Application Gateway
APPGW_IP=$(az network public-ip show \
  --resource-group rg-dronedelivery-dev-*-networking \
  --name pip-agw-* \
  --query ipAddress -o tsv)

# Testar endpoint
curl -X POST "https://dronedelivery.fabrikam.com/v0.1.0/api/deliveryrequests" \
  --resolve dronedelivery.fabrikam.com:443:$APPGW_IP \
  --header 'Content-Type: application/json' \
  -k \
  -d '{
    "confirmationRequired": "None",
    "deadline": "",
    "dropOffLocation": "Seattle",
    "expedited": true,
    "ownerId": "user123",
    "packageInfo": {
      "packageId": "package456",
      "size": "Small",
      "tag": "urgent",
      "weight": 5
    },
    "pickupLocation": "Bellevue",
    "pickupTime": "2025-06-05T14:00:00.000Z"
  }'
```

### **Monitoramento**

1. **Application Insights**: Acesse via portal Azure
2. **Container Insights**: Monitoring do cluster AKS
3. **Application Map**: Visualize dependências entre microserviços

---

## 🔧 Desenvolvimento

### **Estrutura do Projeto**

```
├── infra/                      # Templates Bicep
│   ├── main.bicep             # Template principal
│   ├── modules/               # Módulos reutilizáveis
│   │   ├── networking/        # Hub-spoke, Application Gateway
│   │   ├── compute/           # AKS cluster
│   │   ├── security/          # Key Vault, identidades
│   │   ├── data/              # Cosmos DB, Redis, Service Bus
│   │   └── workload/          # Deploy dos microserviços
│   └── hooks/                 # Scripts de automação
├── src/                       # Código dos microserviços
├── charts/                    # Helm charts
└── azure.yaml                 # Configuração azd
```

### **Build Local**

```bash
# Build de uma imagem específica
docker build -t delivery:local ./src/delivery

# Build de todas as imagens
for service in delivery ingestion workflow dronescheduler package; do
  docker build -t $service:local ./src/$service
done
```

### **Debug Local**

```bash
# Port-forward para um serviço
kubectl port-forward -n backend-dev deployment/delivery 8080:8080

# Executar shell em um pod
kubectl exec -it -n backend-dev deployment/delivery -- /bin/bash

# Ver logs em tempo real
kubectl logs -f -n backend-dev deployment/delivery
```

---

## 📊 Observabilidade

### **Application Insights**

A aplicação está instrumentada com Application Insights para:

- **Tracing distribuído** entre microserviços
- **Métricas de performance** e disponibilidade
- **Mapa de dependências** visual
- **Alertas** automáticos

### **Container Insights**

Monitoring do cluster AKS incluindo:

- **Saúde dos nodes** e pods
- **Uso de CPU e memória**
- **Logs centralizados**
- **Métricas de rede**

### **Dashboards**

```bash
# Abrir Application Insights
azd monitor

# Ver métricas do AKS no portal
az aks browse --resource-group <rg-name> --name <cluster-name>
```

---

## 🔒 Segurança

### **Implementações de Segurança**

- ✅ **Network Security Groups** com regras restritivas
- ✅ **Azure Firewall** para controle de tráfego egress
- ✅ **Private Endpoints** para recursos PaaS
- ✅ **Managed Identities** para autenticação sem passwords
- ✅ **Key Vault** para gerenciamento de secrets
- ✅ **RBAC** integrado com Azure AD
- ✅ **Network Policies** no Kubernetes
- ✅ **Web Application Firewall** no Application Gateway

### **Certificados TLS**

Os certificados são gerados automaticamente:

- **Application Gateway**: `dronedelivery.fabrikam.com`
- **AKS Ingress**: `*.aks-agic.fabrikam.com`

---

## 🚦 Troubleshooting

### **Problemas Comuns**

1. **Deploy falha na criação de grupo AD**

   ```bash
   # Criar grupo manualmente
   az ad group create --display-name "dronedelivery-cluster-admin" --mail-nickname "dronedelivery-admin"
   # Obter Object ID e definir
   azd env set K8S_RBAC_ENTRA_ADMIN_GROUP_OBJECT_ID "<group-id>"
   ```

2. **Pods ficam em Pending**

   ```bash
   # Verificar recursos do cluster
   kubectl describe nodes
   kubectl get events --sort-by=.metadata.creationTimestamp
   ```

3. **Aplicação não responde**

   ```bash
   # Verificar Application Gateway
   az network application-gateway show-health --name <agw-name> --resource-group <rg-name>

   # Verificar ingress
   kubectl get ingress -n backend-dev
   ```

### **Logs e Diagnóstico**

```bash
# Logs do azd
azd logs

# Logs detalhados do Bicep
az deployment group show --resource-group <rg> --name <deployment> --query "properties.error"

# Eventos do Kubernetes
kubectl get events --sort-by=.metadata.creationTimestamp -A

# Status detalhado de um pod
kubectl describe pod <pod-name> -n backend-dev
```

---

## 🤝 Contribuindo

1. Fork o repositório
2. Crie uma branch para sua feature (`git checkout -b feature/nova-feature`)
3. Commit suas mudanças (`git commit -am 'Adiciona nova feature'`)
4. Push para a branch (`git push origin feature/nova-feature`)
5. Abra um Pull Request

---

## 📚 Recursos Adicionais

- [📖 AKS Secure Baseline Original](https://github.com/mspnp/aks-secure-baseline)
- [📖 Azure Developer CLI](https://learn.microsoft.com/azure/developer/azure-developer-cli/)
- [📖 AKS Best Practices](https://learn.microsoft.com/azure/aks/best-practices)
- [📖 Application Gateway + AKS](https://learn.microsoft.com/azure/application-gateway/ingress-controller-overview)

---

## 📄 Licença

Este projeto está licenciado sob a [MIT License](LICENSE.md).

---

**🎉 Parabéns!** Você agora tem uma implementação completamente modernizada do AKS Secure Baseline rodando em produção com total automação!
