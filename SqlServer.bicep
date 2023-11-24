@description('The name of the SQL logical server.')
param sqlServerName string 

@description('Location for all resources.')
param location string = resourceGroup().location

param databaseName string 

param administratorLogin string

@description('Note - This will be passed as variable in the pipeline, for testing it is hardocoded in parameter file')
@secure()
param administratorLoginPassword string           

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    version: '12.0'
    publicNetworkAccess: 'Disabled'
  }
  
}

resource sqlDB 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  parent: sqlServer
  name: databaseName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
  tags: {
    displayName: databaseName
  }
}
