
@description('The name of the function app that you wish to create.')
param appName string
@description('Location for all resources.')
param location string = resourceGroup().location
param paramstorageAccountName string
param adfName string
param serverName string
param databaseName string 
@secure()
param adminLogin string
@secure()
param adminPassword string

var runtime = 'node'
var subscriptionid = subscription().subscriptionId
var connectionstring = 'DRIVER={ODBC Driver 17 for SQL Server};SERVER=${serverName};PORT=1433;DATABASE=${databaseName};UID=${adminLogin};PWD=${adminPassword}'
var storageAccountType = 'Standard_LRS'


resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: paramstorageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'Storage'
  properties: {
    supportsHttpsTrafficOnly: true
    defaultToOAuthAuthentication: true
  }
}

resource hostingPlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: appName
  location: location
  sku: {
    name: 'Y1'
    tier: 'basic'
  }
  properties: {}
}

resource functionApp 'Microsoft.Web/sites@2021-03-01' = {
  name: appName
  location: location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
        connectionStrings: [
        {
          name: 'replicadb'
          connectionString: connectionstring
          type: 'SQLServer'
        }
        ]
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${paramstorageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${paramstorageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
     
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(appName)
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~14'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: runtime
        }
         {
          name: 'ADF_NAME'
          value: adfName
        }
        {
          name: 'SUBSCRIPTION_ID'
          value: subscriptionid
        }

      ]
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
    }
    httpsOnly: true
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}






