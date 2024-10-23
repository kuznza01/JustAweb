param location string = 'northeurope'
param rootName string 
@allowed([
  'prod'
  'nonprod'
])
param environmentType string = 'nonprod'

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
