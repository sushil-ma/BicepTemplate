
@description('Location for all resources.')
param location string = resourceGroup().location

 
param vnetName string
var vnetAddressPrefix = '10.0.0.0/16'
var subnet1Prefix = '10.0.0.0/24'
param subnet1Name string
param privateEndpointName string
param pvtEndpointDnsGroupName string
param publicIpAddressName string
param networkInterfaceName string
var pvtEndpointDnsGroupNamevar = '${privateEndpointName}/${pvtEndpointDnsGroupName}'
var privateDnsZoneName = 'privatelink${environment().suffixes.sqlServerHostname}'
param sqlServer string



resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  parent: vnet
  name: subnet1Name
  properties: {
    addressPrefix: subnet1Prefix
    privateEndpointNetworkPolicies: 'Disabled'
  }
}


resource existingsqlServer 'Microsoft.Sql/servers@2022-05-01-preview' existing = {
  name: sqlServer  
}


resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = if (existingsqlServer.id != null) {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnet.id
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: existingsqlServer.id
          groupIds: [
            'sqlServer'
          ]
        }
      }
    ]
  }
  dependsOn: [
    vnet
  ]
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
  properties: {}
  dependsOn: [
    vnet
  ]
}

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: '${privateDnsZoneName}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource pvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: pvtEndpointDnsGroupNamevar
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
  dependsOn: [
    privateEndpoint
  ]
}

resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: publicIpAddressName
  location: location
  tags: {
    displayName: publicIpAddressName
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2021-05-01' = {
  name: networkInterfaceName
  location: location
  tags: {
    displayName: networkInterfaceName
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIpAddress.id
          }
          subnet: {
            id: subnet.id
          }
        }
      }
    ]
  }
  dependsOn: [
    vnet
  ]
}
