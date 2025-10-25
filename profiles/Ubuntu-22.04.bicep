param templateName string

module ubuntu 'common/ubuntu.bicep' = {
  name: 'Ubuntu'
  scope: resourceGroup('AzurePipelinesImageBuilder')
  params: {
    imageName: 'Ubuntu-22.04'
    templateName: templateName
    vmSize: 'Standard_D2alds_v6'
    osDiskSizeGB: 110
    sourcePublisher: 'Canonical'
    sourceOffer: '0001-com-ubuntu-server-jammy'
    sourceSku: '22_04-lts-gen2'
    diskControllerTypes: 'SCSI,NVMe'
  }
}
