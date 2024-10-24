param location string
param rootName string
@allowed([
  'prod'
  'nonprod'
])
param environmentType string = 'nonprod'
@allowed([
  'EC'
  'EC-HSM'
  'RSA'
  'RSA-HSM'
])
param keyType string = 'EC'
param keyOps array = [] /* ["sign", "verify", "encrypt", "decrypt", " wrapKey", "unwrapKey"] or leave blank for all operations*/
param keySize int = 2048
@allowed([
  ''
  'P-256'
  'P-256K'
  'P-384'
  'P-521'
])
param curveName string = 'P-384'
param objectId string

var skuName = (environmentType == 'prod') ? 'premium' : 'standard'
var keyName = '${rootName}key'
var vaultName = '${rootName}vault'
var tenantId = subscription().tenantId


resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: vaultName
  location: location
  properties: {
    accessPolicies:[
      {
        tenantId: tenantId
        objectId: objectId
        permissions: {
          keys: [
            'get'
            'list'
            'create'
            'delete'
            'recover'
            'backup'
            'restore'
            'import'
            'update'
          ]
          secrets: [
            'get'
            'list'
            'set'
            'delete'
            'recover'
            'backup'
            'restore'
          ]
          certificates: [
            'get'
            'list'
            'update'
            'create'
            'import'
            'delete'
            'recover'
            'backup'
            'restore'
            'managecontacts'
            'getissuers'
            'listissuers'
            'setissuers'
            'deleteissuers'
            'manageissuers'
          ]
        }
      }
    ]
    enableRbacAuthorization: false
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enabledForDeployment: true
    enabledForDiskEncryption: true
    enabledForTemplateDeployment: true
    tenantId: subscription().tenantId
    sku: {
      name: skuName
      family: 'A'
    }
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}

resource key 'Microsoft.KeyVault/vaults/keys@2023-07-01' = {
  parent: keyVault
  name: keyName
  properties: {
    kty: keyType
    keyOps: keyOps
    keySize: keySize
    curveName: curveName
  }
}

output proxyKey object = key.properties
