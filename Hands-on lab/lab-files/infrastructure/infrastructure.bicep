param studentprefix string = 'Your 3 letter abbreviation here'
param cosmosDBName string = 'fabmedical-cdb-${studentprefix}'
param webappName string = 'fabmedical-web-${studentprefix}'
param planName string = 'fabmedical-plan-${studentprefix}'
param resourceGroupLocation string = resourceGroup().location

var location1 = 'westeurope'
var location2 = 'northeurope'

resource cosmosdb 'Microsoft.DocumentDB/databaseAccounts@2021-11-15-preview' = {
  name: cosmosDBName
  location: resourceGroupLocation
  kind: 'MongoDB'
  properties: {
    locations: [
      {
        locationName: location1
        failoverPriority: 0
        isZoneRedundant: false
      }
      {
        locationName: location2
        failoverPriority: 1
        isZoneRedundant: true
      }
    ]
    enableMultipleWriteLocations: true
    enableFreeTier: true
    databaseAccountOfferType: 'Standard'
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: planName
  location: resourceGroupLocation
  properties: {
    reserved: true
  }
  sku: {
    name: 'F1'
  }
  kind: 'linux'
}

resource webApp 'Microsoft.Web/sites@2020-06-01' = {
  name: webappName
  location: resourceGroupLocation
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'DOCKER|nginx'
    }
  }
}

#disable-next-line outputs-should-not-contain-secrets
output mongodbConnectionString string = listSecrets(cosmosdb.id, cosmosdb.apiVersion).connectionStrings[0].connectionString
