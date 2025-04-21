# Bicep Deployment

Use the Azure CLI to deploy resources.

## Overview

The network configuration in `network.bicep` must be deployed before scale sets.

Each scale set, defined in an `agent-pool-*.bicep` file, can be independently deployed.
However, each scale set requires its own subnet defined in `network.bicep`.

The `network-functions.bicep` file explains how the subnets are organized.

## Testing and Deployment

### Check Mode

The following commands can be used to see what changes will be applied.

```shell
az deployment group what-if -f network.bicep -g AzurePipelines -p location=EastUS2
```

```shell
az deployment group what-if -f agent-pool-ipv4.bicep -g AzurePipelines -p location=EastUS2
```

### Create / Update

Replace `what-if` with `create` in the above commands to create resources or update existing resources.
