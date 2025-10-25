param templateName string

module ubuntu 'common/ubuntu.bicep' = {
  name: 'Ubuntu'
  scope: resourceGroup('AzurePipelinesImageBuilder')
  params: {
    imageName: 'Ubuntu-24.04-SCSI'
    templateName: templateName
    vmSize: 'Standard_F2s_v2'
    osDiskSizeGB: 30
    sourcePublisher: 'Canonical'
    sourceOffer: 'ubuntu-24_04-lts'
    sourceSku: 'server'
    diskControllerTypes: 'SCSI'
  }
}
