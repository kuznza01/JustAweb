param location string
param rootName string
param cosmosDBDatabaseThroughput int = 400
@allowed([
  'prod'
  'nonprod'
])
param environmentType string = 'nonprod'

var cosmosDBContainerPartitionKey = '/droneId'
var logAnalyticsWorkspaceName = '${rootName}logs'
var cosmosDBAccountDiagnosticSettingsName = 'route-logs-to-log-analytics'
var storageAccountSkuName = (environmentType == 'prod') ? 'Standard_GRS' : 'Standard_LRS'

resource cosmosDB 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' = {
  name: '${rootName}cosmosdb'
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
  }
}

resource cosmosDBDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-04-15' = {
  parent: cosmosDB
  name: '${rootName}data'
  location: location
  properties: {
    resource: {
      id: '${rootName}data'
    }
    options: {
      throughput: cosmosDBDatabaseThroughput
    }
  }
  resource container 'containers@2023-04-15' = {
    name: '${rootName}container'
    properties: {
      resource: {
        id: '${rootName}container'
        partitionKey: {
          kind: 'Hash'
          paths: [
            cosmosDBContainerPartitionKey
          ]
        }
      }
      options: {}
    }
  }  
}
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: {
    retentionInDays: 30
  }
}

resource cosmosdbaccountDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: cosmosDB
  name: cosmosDBAccountDiagnosticSettingsName
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'DataPlaneRequests'
        enabled: true
      }
    ]
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: '${rootName}bloblogs'
  location: location
  sku: {
    name: storageAccountSkuName
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
  resource blobService 'blobServices' = {
    name: 'default'
    properties: {
      changeFeed: {
        enabled: true
      }
    }
  }
}


resource storageAccountBlobDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: storageAccount::blobService
  name: cosmosDBAccountDiagnosticSettingsName
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'StorageRead'
        enabled: true
      }
      {
        category: 'StorageWrite'
        enabled: true
      }
      {
        category: 'StorageDelete'
        enabled: true
      }
    ]
  }
}
