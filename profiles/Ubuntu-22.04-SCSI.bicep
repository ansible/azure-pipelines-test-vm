param templateName string

module ubuntu 'common/ubuntu.bicep' = {
  name: 'Ubuntu'
  scope: resourceGroup('AzurePipelinesImageBuilder')
  params: {
    imageName: 'Ubuntu-22.04-SCSI'
    templateName: templateName
    vmSize: 'Standard_F2s_v2'
    osDiskSizeGB: 30
    sourcePublisher: 'Canonical'
    sourceOffer: '0001-com-ubuntu-server-jammy'
    sourceSku: '22_04-lts-gen2'
    diskControllerTypes: 'SCSI'
  }
}
