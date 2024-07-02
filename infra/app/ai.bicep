metadata description = 'Create AI accounts.'

param accountName string
param location string = resourceGroup().location
param tags object = {}

var deployments = [
  {
    name: 'completions'
    skuCapacity: 5
    modelName: 'gpt-35-turbo'
    modelVersion: '0613'
  }
  {
    name: 'embeddings'
    skuCapacity: 5
    modelName: 'text-embedding-ada-002'
    modelVersion: '2'
  }
]

module openAiAccount '../core/ai/openAI/account.bicep' = {
  name: 'openai-account'
  params: {
    name: accountName
    location: location
    tags: tags
    kind: 'OpenAI'
    sku: 'S0'
    enablePublicNetworkAccess: true
  }
}

@batchSize(1)
module openAiModelDeployments '../core/ai/openAI/deployment.bicep' = [
  for (deployment, _) in deployments: {
    name: 'openai-model-deployment-${deployment.name}'
    params: {
      name: deployment.name
      parentAccountName: openAiAccount.outputs.name
      skuName: 'Standard'
      skuCapacity: deployment.skuCapacity
      modelName: deployment.modelName
      modelVersion: deployment.modelVersion
      modelFormat: 'OpenAI'
    }
  }
]

output name string = openAiAccount.outputs.name
output endpoint string = openAiAccount.outputs.endpoint
output deployments array = [
  for (_, index) in deployments: {
    name: openAiModelDeployments[index].outputs.name
  }
]

