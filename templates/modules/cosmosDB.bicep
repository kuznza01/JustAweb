param location string
param rootName string
param cosmosDBDatabaseThroughput int = 400

var cosmosDBContainerPartitionKey = '/droneId'

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
