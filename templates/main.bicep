param location string = 'northeurope'
param rootName string 
@allowed([
  'prod'
  'nonprod'
])
param environmentType string = 'nonprod'
param objectId string

module keyVault 'modules/keyvault.bicep' = {
  name: 'keyVault'
  params: {
    location: location
    rootName: rootName
    environmentType: environmentType
    objectId: objectId
  }
}

module storage 'modules/storage.bicep' = {
  name: 'storage'
  params: {
    location: location
    rootName: '${rootName}sa'
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

module appService 'modules/appService.bicep' = {
  name: 'appService'
  params: {
    location: location
    rootName: rootName
    environmentType: environmentType
  }
}

output appServiceAppHostName string = appService.outputs.appServiceAppHostName
output proxyKey object = keyVault.outputs.proxyKey
