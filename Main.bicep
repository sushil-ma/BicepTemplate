
@description('The name of the function app that you wish to create.')
param appName string
@description('Location for all resources.')
param location string = resourceGroup().location
param paramstorageAccountName string
param adfName string
param keyVaultName string
param SQLkeyVaultName string
param databaseName string 
param logAnalyticsWorkspaceName string


@description('Specifies whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault.')
param enabledForDeployment bool = false
@description('Specifies whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys.')
param enabledForDiskEncryption bool = false
@description('Specifies whether Azure Resource Manager is permitted to retrieve secrets from the key vault.')
param enabledForTemplateDeployment bool = false
@description('Specifies the object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault. The object ID must be unique for the list of access policies. Get it by using Get-AzADUser or Get-AzADServicePrincipal cmdlets.')
param objectId string


@description('Specifies the name of the secret that you want to create.')

param UserId string

@description('Specifies the name of the secret that you want to create.')
@secure()
param secretPasswordName string

@description('Specifies the value of the secret that you want to create.')
@secure()
param secretPasswordValue string


@description('Specifies the name of the secret that you want to create.')
param SqlAdminIdName string

@description('Specifies the name of the secret that you want to create.')
@secure()
param secretAdminPasswordName string


@description('Specifies the value of the secret that you want to create.')
@secure()
param secretAdminPasswordValue string 

@description('The name of the SQL logical server.')
param sqlServerName string 


@description('Specifies the name of the secret that you want to create.')
@secure()
param secretOntoTextPwdName string
@description('Specifies the value of the secret that you want to create.')
@secure()
param secretOntoTextPwdValue string

@description('Specify the email address where the alerts are sent to.')
param emailAddress string

@description('Specify the email address name where the alerts are sent to.')
param emailName string 
param adminPassw string
param resourcegroupname string

param privateEndpointName string
param pvtEndpointDnsGroupName string
param publicIpAddressName string
param networkInterfaceName string
param subnet1Name string
param vnetName string


module resourcegroup 'ResourceGroup.bicep' = {
  name: 'deployResourceGroup'
  scope:subscription()
  params: {
    resourcegroupname: resourcegroupname
    location: location
  
  }
  
  }



resource SQLkv 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: SQLkeyVaultName
  scope: resourceGroup(subscription().subscriptionId, resourceGroup().name )
  
}

module keyvault './keyvault.bicep' = {
  name: 'deploykeyvault'
  params: {
    keyVaultName: keyVaultName
    location: location 
    objectId: objectId 
    secretPasswordName:secretPasswordName
    secretPasswordValue: secretPasswordValue
    secretOntoTextPwdValue: secretOntoTextPwdValue
    secretOntoTextPwdName: secretOntoTextPwdName
    enabledForDeployment: enabledForDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enabledForTemplateDeployment: enabledForTemplateDeployment
  }
}


module SQLkeyvault './KeyVault_SQLServer.bicep' = {
  name: 'deploysqlkeyvault'
  params: {
    keyVaultName: SQLkeyVaultName
    location: location 
    objectId: objectId 
    secretAdminPasswordName:secretAdminPasswordName
    secretAdminPasswordValue: secretAdminPasswordValue
    enabledForDeployment: enabledForDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enabledForTemplateDeployment: enabledForTemplateDeployment
  }
}




module functionapp './FunctionApp.bicep' = {
   name: 'deployfunctionapp'
  params: {
        appName: appName
    location: location
    paramstorageAccountName: paramstorageAccountName
adfName: adfName
 serverName: sqlServerName
 databaseName: databaseName
    adminLogin:  UserId
    adminPassword: adminPassw
  }

}


module SQLServer './SqlServer.bicep' = {
  name: 'deploySQL'
  params: {
    sqlServerName: sqlServerName
    databaseName : databaseName
    administratorLogin : SqlAdminIdName
    administratorLoginPassword : SQLkv.getSecret('sqlukp-dev-1-pwd')
    location:location


  }
  dependsOn:[SQLkeyvault]
}


module ADF './ADF_Bicep.bicep' = {
  name: 'deployADF'
  params: {
    dataFactoryName: adfName
    location: location

  }
}
  


module Alerts './Alerts_bicep.bicep' = {
  name: 'deployAlerts'
  params: {
   emailAddress:emailAddress
   emailName:emailName
     
  }
}


module Monitoring './Monitoring_bicep.bicep' = {
  name: 'deployMonitoring'
  params: {
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
     location:location

  }
}

module PrivateEndpoint './privateEndpoint.bicep' = {
  name: 'deployPrivateEndpoint'
  params: {
    location:location
    networkInterfaceName: networkInterfaceName
     subnet1Name:subnet1Name
    privateEndpointName:privateEndpointName
    publicIpAddressName:publicIpAddressName
    pvtEndpointDnsGroupName:pvtEndpointDnsGroupName
    vnetName :vnetName
    sqlServer: sqlServerName

  }
dependsOn:[SQLServer]
}








