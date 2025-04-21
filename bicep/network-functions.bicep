// Functions for calculating virtual network subnets.
//
// There are two categories of subnets defined here:
//
// * Standard subnet (IPv4 /24). Used for all resources requiring network access, except scale sets.
// * Pool subnet (IPv4 /22). Sized to accommodate a max-size scale set (1000 instances, 1024 addresses).
//   Each scale set should use its own pool.
//
// Each IPv4 subnet `A.B.C.0/N` is associated with an IPv6 subnet `fd00:A:B:C::/64`.
// The IPv6 subnets are expressed such that their string representation matches the associated IPv4 subnet.
// This simplifies subnets as strings, at the cost of increased complexity for decimal based subnet calculations.

var subnetV4 = '10.0.0.0/8'
var subnetV6 = 'fd00:10::/32'

@description('Each location has its own arbitrary and unique 2-digit subnet index.')
var locationSubnetIndexes = {
  EastUS2: 12
  SouthCentralUS: 14
}

@minValue(0)
@maxValue(11)
@description('Index used to calculate a standard subnet index.')
type standardIndex = int

@minValue(0)
@maxValue(21)
@description('Index used to calculate a pool subnet index.')
type poolIndex = int

@minValue(0)
@maxValue(99)
@description('Index of an IPv4 subnet which can be converted for use as an IPv6 subnet.')
type subnetIndex = int

@description('Convert a subnet index from IPv4 to IPv6.')
func getIPv6SubnetIndex(index subnetIndex) int => index + ((index / 10) * 6)

@description('Convert a pool index to a pool subnet index.')
func getPoolSubnetIndex(poolIndex poolIndex) subnetIndex => 12 + poolIndex * 4

@export()
@description('Get subnets for the given location.')
func getSubnet(location string) object => {
  v4: cidrSubnet(subnetV4, 16, locationSubnetIndexes[location])
  v6: cidrSubnet(subnetV6, 48, getIPv6SubnetIndex(locationSubnetIndexes[location]))
}

@export()
@description('Get standard subnets for the given location and index.')
func getStandardSubnets(location string, standardIndex standardIndex) array => [
  cidrSubnet(getSubnet(location).v4, 24, standardIndex)
  cidrSubnet(getSubnet(location).v6, 64, getIPv6SubnetIndex(standardIndex))
]

@export()
@description('Get pool subnets for the given location and index.')
func getPoolSubnets(location string, poolIndex poolIndex) array => [
  cidrSubnet(getSubnet(location).v4, 22, getPoolSubnetIndex(poolIndex) / 4)
  cidrSubnet(getSubnet(location).v6, 64, getIPv6SubnetIndex(getPoolSubnetIndex(poolIndex)))
]
