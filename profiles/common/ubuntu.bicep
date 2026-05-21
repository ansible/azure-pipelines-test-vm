param imageName string
param templateName string
param vmSize string
param osDiskSizeGB int
param sourcePublisher string
param sourceOffer string
param sourceSku string
param diskControllerTypes string

param location string = 'EastUS2'
param buildTimeoutMinutes int = 60
param targetRegions array = []
param galleryName string = 'AzurePipelinesGallery'
param builderIdentity string = 'AzureImageBuilderIdentity'

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2025-05-31-preview' existing = {
  name: builderIdentity
}

resource gallery 'Microsoft.Compute/galleries@2025-03-03' existing = {
  name: galleryName

  resource imageDefinition 'images' = {
    name: imageName
    location: location
    properties: {
      hyperVGeneration: 'V2'
      osState: 'Generalized'
      osType: 'Linux'
      architecture: 'x64'
      identifier: {
       publisher: 'Ansible'
       offer: 'AzurePipelines'
       sku: imageName
      }
      features: [
        {
          name: 'IsAcceleratedNetworkSupported'
          value: 'True'
        }
        {
          name: 'SecurityType'
          value: 'TrustedLaunchSupported'
        }
        {
          name: 'DiskControllerTypes'
          value: diskControllerTypes
        }
      ]
    }
  }
}

resource imageTemplate 'Microsoft.VirtualMachineImages/imageTemplates@2025-10-01' = {
  name: templateName
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity.id}': {}
    }
  }
  location: location
  properties: {
    buildTimeoutInMinutes: buildTimeoutMinutes
    customize: [
      {
        name: 'Customize'
        type: 'Shell'
        inline: [
          loadTextContent('ubuntu-customize.sh')
        ]
      }
    ]
    distribute: [
      {
        galleryImageId: gallery::imageDefinition.id
        targetRegions: targetRegions
        runOutputName: imageName
        type: 'SharedImage'
      }
    ]
    source: {
      publisher: sourcePublisher
      offer: sourceOffer
      sku: sourceSku
      version: 'latest'
      type: 'PlatformImage'
    }
    vmProfile: {
      vmSize: vmSize
      osDiskSizeGB: osDiskSizeGB
    }
    optimize: {
      vmBoot: {
        state: 'Enabled'
      }
    }
  }
}
