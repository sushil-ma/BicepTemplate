targetScope = 'subscription'

param resourcegroupname string 
param location string = 'uksouth'
resource rg 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: resourcegroupname
  location: location
}
