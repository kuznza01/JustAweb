param location string = 'northeurope'
param rootName string 
@allowed([
  'prod'
  'nonprod'
])
param environmentType string = 'nonprod'

var storageAccountSkuName = (environmentType == 'prod') ? 'Standard_GRS' : 'Standard_LRS'
var appServicePlanSkuName = (environmentType == 'prod') ? 'P2v3' : 'F1'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: '${rootName}sa'
  location: location
  sku: {
    name: storageAccountSkuName
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

module appService 'modules/appService.bicep' = {
  name: 'appService'
  params: {
    location: location
    rootName: rootName
    environmentType: environmentType
  }
}

module cosmosDB 'modules/cosmosDB.bicep' = {
  name: 'cosmosDB'
  params: {
    location: location
    rootName: rootName
  }
}

output appServiceAppHostName string = appService.outputs.appServiceAppHostName
