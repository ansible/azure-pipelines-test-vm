param templateName string

module ubuntu 'common/ubuntu.bicep' = {
  name: 'Ubuntu'
  scope: resourceGroup('AzurePipelinesImageBuilder')
  params: {
    imageName: 'Ubuntu-24.04'
    templateName: templateName
    vmSize: 'Standard_D2alds_v6'
    osDiskSizeGB: 110
    sourcePublisher: 'Canonical'
    sourceOffer: 'ubuntu-24_04-lts'
    sourceSku: 'server'
    diskControllerTypes: 'SCSI,NVMe'
  }
}
