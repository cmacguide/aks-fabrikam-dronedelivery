// Observability module - Application Insights and Azure Monitor configuration
targetScope = 'resourceGroup'

// ============================================================================
// PARAMETERS
// ============================================================================

@description('Primary deployment location')
param location string
@description('Resource prefix identifier for resource naming')
param resourceSuffix string
@description('Log Analitics Workspace SKU')
@allowed([
  'PerGB2018'
  'Free'
  'Standalone'
  'CapacityReservation'
])
param logAnalyticsWorkspaceSku string
@description('Retention period (in days) for logs')
@minValue(30)
@maxValue(730)
param retentionInDays int
@description('Resource tags')
param tags object = {}
// @description('Recursos para os quais serão criados diagnosticSettings')
// param diagnosticTargets array = []

// ============================================================================
// VARIABLES
// ============================================================================

var workspaceName = 'la-${resourceSuffix}-01'
var appInsightsName = 'ai-${resourceSuffix}'

// ============================================================================
// RESOURCES
// ============================================================================

// Log Analytics Workspace
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: workspaceName
  location: location
  tags: tags
  properties: {
    sku: {
      name: logAnalyticsWorkspaceSku
    }
    retentionInDays: retentionInDays
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

// Application Insights
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  tags: union(tags, {
    Service: 'ApplicationInsights'
    Purpose: 'DistributedTracing'
  })
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    RetentionInDays: retentionInDays
    DisableIpMasking: false
    DisableLocalAuth: false
  }
}

// Diagnostic Settings para múltiplos recursos
// @batchSize(1)
// module diagnostics 'diagnosticSettings.bicep' = [
//   for (target, index) in diagnosticTargets: {
//     name: 'diag-${target.name}-${index}'
//     params: {
//       name: 'diag-${target.name}'
//       targetResourceId: target.resourceId
//       resourceType: target.type
//       workspaceId: logAnalytics.id
//     }
//   }
// ]

// Configurações específicas por tipo de recurso
var logConfigurations = {
  aks: [
    {
      category: 'kube-apiserver'
      enabled: true
    }
    {
      category: 'kube-audit'
      enabled: true
    }
    {
      category: 'kube-audit-admin'
      enabled: true
    }
    {
      category: 'kube-controller-manager'
      enabled: true
    }
    {
      category: 'kube-scheduler'
      enabled: true
    }
    {
      category: 'cluster-autoscaler'
      enabled: true
    }
    {
      category: 'guard'
      enabled: true
    }
  ]
  appgateway: [
    {
      category: 'ApplicationGatewayAccessLog'
      enabled: true
    }
    {
      category: 'ApplicationGatewayPerformanceLog'
      enabled: true
    }
    {
      category: 'ApplicationGatewayFirewallLog'
      enabled: true
    }
  ]
  keyvault: [
    {
      category: 'AuditEvent'
      enabled: true
    }
    {
      category: 'AzurePolicyEvaluationDetails'
      enabled: true
    }
  ]
  firewall: [
    {
      category: 'AzureFirewallApplicationRule'
      enabled: true
    }
    {
      category: 'AzureFirewallNetworkRule'
      enabled: true
    }
  ]
  metrics: [
    {
      category: 'AllMetrics'
      enabled: true
    }
  ]
  generic: [
    {
      categoryGroup: 'AllLogs'
      enabled: true
    }
  ]
}

// Configurações de métricas
var metricsConfiguration = [
  {
    category: 'AllMetrics'
    enabled: true
  }
]

// Configuration para microservices
output observabilityConfig object = {
  applicationInsights: {
    name: appInsights.name
    instrumentationKey: appInsights.properties.InstrumentationKey
    connectionString: appInsights.properties.ConnectionString
  }
  logAnalytics: {
    workspaceId: logAnalytics.id
    workspaceName: logAnalytics.name
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

output logAnalyticsWorkspaceId string = logAnalytics.id
output logAnalyticsWorkspaceName string = logAnalytics.name
output applicationInsightsId string = appInsights.id
output applicationInsightsName string = appInsights.name
output instrumentationKey string = appInsights.properties.InstrumentationKey
output connectionString string = appInsights.properties.ConnectionString
output logConfigurationsObj object = logConfigurations
output logConfigurationsObjGeneric array = logConfigurations.generic
output metricsConfigurationArr array = metricsConfiguration
