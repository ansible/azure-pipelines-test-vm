param builderIdentity string = 'AzureImageBuilderIdentity'
param galleryName string = 'AzurePipelinesGallery'
param roleName string = 'Image Builder Service'

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: builderIdentity
  location: resourceGroup().location
}

resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
  name: guid(resourceGroup().id, roleName)
  properties: {
    roleName: roleName
    description: 'Image Builder access to create virtual machine images for use with Azure Pipelines.'
    type: 'CustomRole'
    assignableScopes: [
      resourceGroup().id
    ]
    permissions: [
      {
        actions: [
          'Microsoft.Compute/galleries/read'
          'Microsoft.Compute/galleries/images/read'
          'Microsoft.Compute/galleries/images/versions/read'
          'Microsoft.Compute/galleries/images/versions/write'
          'Microsoft.Compute/images/write'
          'Microsoft.Compute/images/read'
          'Microsoft.Compute/images/delete'
        ]
      }
    ]
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(roleDefinition.id, identity.id)
  properties: {
    roleDefinitionId: roleDefinition.id
    principalId: identity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource gallery 'Microsoft.Compute/galleries@2023-07-03' = {
  name: galleryName
  location: resourceGroup().location
}
