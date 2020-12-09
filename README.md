# azure-pipelines-test-vm
Virtual machine image builder for running ansible-test on Azure Pipelines.

## Updating, Building and Deploying a Virtual Machine Image

The following instructions will use the ``Ubuntu-18.04-Minimal-30GB`` profile and the ``AgentPool-Standard_F2s_v2-EastUS2`` scale set in the ``AzurePipelines`` resource group as examples.
Substitute the desired values as needed.

> NOTE: These instructions assume the profile and scale set already exist.
> Additional steps are required if one or both must be created.

### Update the Configuration

Make changes to the ``lookup_plugins/annotated_pull_commands.py`` plugin or the profile configuration in the ``image/configurations/Ubuntu-18.04-Minimal-30GB.yml`` file.

> IMPORTANT: Do not edit the files in the ``image/templates/`` directory.
 
### Update the Template

Update the profile template with the command:

``
ansible-playbook create-template.yml -i inventory.yml -e profile=Ubuntu-18.04-Minimal-30GB
``

### Commit the Changes

Commit the changes made manually during the first step and automatically during the second step.

### Build the Image

Build the image defined by the template with the command:

``
ansible-playbook create-image.yml -i inventory.yml -e profile=Ubuntu-18.04-Minimal-30GB
``

> NOTE: This step is expected to run for more than an hour. Come back and check on it later.

### Deploy the Image

Retrieve the list of image versions with the command:

``
ansible-playbook -i inventory.yml list-image-versions.yml -e profile=Ubuntu-18.04-Minimal-30GB
``

Once the image has been built, it can be deployed to a scale set with the command:

``
ansible-playbook update-scaleset.yml -i inventory.yml -e profile=Ubuntu-18.04-Minimal-30GB -e scaleset_resource_group=AzurePipelines -e scaleset=AgentPool-Standard_F2s_v2-EastUS2 -e image_version=0.24528.6373
``

> NOTE: The ``image_version`` used in the above command was retrieved from the list returned by the previous command.
