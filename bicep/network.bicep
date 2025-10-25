param location string

param securityGroupName string = 'SecurityGroup-${ location }'

import {
  getSubnet
  getStandardSubnets
  getPoolSubnets
} from 'network-functions.bicep'

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2024-03-01' = {
  name: securityGroupName
  location: location
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-03-01' = {
  name: 'Network-${ location }'
  location: location
  properties: {
    privateEndpointVNetPolicies: 'Disabled'
    addressSpace: {
      addressPrefixes: [
        getSubnet(location).v4
        getSubnet(location).v6
      ]
    }
    subnets: [
      // Standard subnets
      {
        name: 'Default'
        properties: {
          privateEndpointNetworkPolicies: 'Enabled'
          addressPrefixes: getStandardSubnets(location, 10)
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          privateEndpointNetworkPolicies: 'Enabled'
          addressPrefixes: getStandardSubnets(location, 11)
        }
      }
      // Pool subnets
      {
        name: 'AgentPool-IPv4'
        properties: {
          privateEndpointNetworkPolicies: 'Enabled'
          addressPrefixes: getPoolSubnets(location, 1)
          networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
        }
      }
      {
        name: 'AgentPool-DualStack'
        properties: {
          privateEndpointNetworkPolicies: 'Enabled'
          addressPrefixes: getPoolSubnets(location, 2)
          networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
        }
      }
      {
        name: 'AgentPool-Experimental'
        properties: {
          privateEndpointNetworkPolicies: 'Enabled'
          addressPrefixes: getPoolSubnets(location, 3)
          networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
        }
      }
      {
        name: 'AgentPool-Experimental-SCSI'
        properties: {
          privateEndpointNetworkPolicies: 'Enabled'
          addressPrefixes: getPoolSubnets(location, 4)
          networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
        }
      }
    ]
  }
}
