param location string

param acceleratedNetworking bool = true

param skuName string = 'Standard_F2s_v2'
param label string = 'AgentPool-Experimental-SCSI'
param name string = '${ label }-${ location }'
param virtualNetworkName string = 'Network-${ location }'
param subnetName string = label

param galleryResourceGroupName string = 'AzurePipelinesImageBuilder'
param galleryName string = 'AzurePipelinesGallery'
param imageName string = 'Ubuntu-24.04-SCSI'
param versionName string = '1.0.0'
param computerNamePrefix string = 'agent'

param username string = 'manager'
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
        }
        allowExtensionOperations: true
      }
      storageProfile: {
        osDisk: {
          osType: 'Linux'
          diffDiskSettings: {
            option: 'Local'
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
            name: 'Primary'
            properties: {
              primary: true
              enableAcceleratedNetworking: acceleratedNetworking
              disableTcpStateTracking: false
              enableIPForwarding: false
              ipConfigurations: [
                {
                  name: 'IPv4'
                  properties: {
                    subnet: {
                      id: virtualNetwork::subnet.id
                    }
                    privateIPAddressVersion: 'IPv4'
                    publicIPAddressConfiguration: {
                      name: 'PublicIPv4'
                      sku: {
                        name: 'Standard'
                        tier: 'Regional'
                      }
                      properties: {
                        publicIPAddressVersion: 'IPv4'
                      }
                    }
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
