param location string

param acceleratedNetworking bool = false

param skuName string = 'Standard_F2s_v2'
param label string = 'AgentPool-CGroupV2'
param name string = '${ label }-${ location }'
param virtualNetworkName string = 'Network-${ location }'
param subnetName string = 'AgentPool-Standard_F2s_v2'

param namePrefixes object = {
  EastUS2: 'agenta215'
  SouthCentralUS: 'agent1c8a'
}

param galleryResourceGroupName string = 'AzurePipelinesImageBuilder'
param galleryName string = 'AzurePipelinesGallery'
param imageName string = 'Ubuntu-22.04-Minimal-30GB'
param versionName string = '0.25610.38692'
param computerNamePrefix string = namePrefixes[location]

param username string = 'ubuntu'
@secure()
param password string = newGuid()

resource gallery 'Microsoft.Compute/galleries@2023-07-03' existing = {
  name: galleryName
  scope: resourceGroup(galleryResourceGroupName)

  resource image 'images' existing = {
    name: imageName

    resource version 'versions' existing = {
      name: versionName
    }
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-03-01' existing = {
  name: virtualNetworkName

  resource subnet 'subnets' existing = {
    name: subnetName
  }
}

resource scaleSet 'Microsoft.Compute/virtualMachineScaleSets@2024-07-01' = {
  name: name
  location: location
  sku: {
    name: skuName
  }
  properties: {
    singlePlacementGroup: false
    orchestrationMode: 'Uniform'
    overprovision: false
    platformFaultDomainCount: 1
    upgradePolicy: {
      mode: 'Manual'
    }
    virtualMachineProfile: {
      osProfile: {
        computerNamePrefix: computerNamePrefix
        adminUsername: username
        adminPassword: password
        linuxConfiguration: {
          disablePasswordAuthentication: false
          provisionVMAgent: true
          enableVMAgentPlatformUpdates: false
        }
        allowExtensionOperations: true
      }
      storageProfile: {
        osDisk: {
          osType: 'Linux'
          diffDiskSettings: {
            option: 'Local'
            placement: 'CacheDisk'
          }
          createOption: 'FromImage'
          caching: 'ReadOnly'
          managedDisk: {
            storageAccountType: 'Standard_LRS'
          }
        }
        imageReference: {
          id: gallery::image::version.id
        }
      }
      networkProfile: {
        networkInterfaceConfigurations: [
          {
            name: '${ computerNamePrefix }Nic'
            properties: {
              primary: true
              enableAcceleratedNetworking: acceleratedNetworking
              disableTcpStateTracking: false
              enableIPForwarding: false
              ipConfigurations: [
                {
                  name: '${ computerNamePrefix }IPConfig'
                  properties: {
                    subnet: {
                      id: virtualNetwork::subnet.id
                    }
                    privateIPAddressVersion: 'IPv4'
                  }
                }
              ]
            }
          }
        ]
      }
    }
  }
}
