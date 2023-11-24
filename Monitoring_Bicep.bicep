param location string = resourceGroup().location

param logAnalyticsWorkspaceName string 
param logAnalyticsWorkspaceSku string = 'PerGB2018'


resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: {
    sku: {
      name: logAnalyticsWorkspaceSku
    }
  }
}

resource monitoringDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2017-05-01-preview' = {
  scope: logAnalyticsWorkspace
  name: 'monitoringSettings'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'Audit'
        enabled: true
      }
     
    ]
  }
}
