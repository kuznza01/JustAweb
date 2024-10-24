param location string
param rootName string
@allowed([
  'prod'
  'nonprod'
])
param environmentType string

var appServicePlanSkuName = (environmentType == 'prod') ? 'P2v3' : 'F1'

resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: '${rootName}asp'
  location: location
  sku: {
    name: appServicePlanSkuName
    tier: 'Free'
  }
}

resource appserviceapp 'Microsoft.Web/sites@2021-02-01' = {
  name: '${rootName}asa'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
  }
}

output appServiceAppHostName string = appserviceapp.properties.defaultHostName
