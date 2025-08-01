# azure-pipelines-test-vm
Virtual machine image builder for running ansible-test on Azure Pipelines.

## Updating, Building and Deploying a Virtual Machine Image

These instructions will use the ``Ubuntu-22.04-Minimal-30GB`` image in the examples.
Substitute the desired image as needed.

> NOTE: These instructions assume the profile and scale set already exist.
> Additional steps are required if one or both must be created.

### Update the Configuration

Update the ``image/customize.sh`` script,
or the profile configuration in the ``image/configurations/Ubuntu-22.04-Minimal-30GB.yml`` file.

> IMPORTANT: Do not edit the files in the ``image/templates/`` directory.
 
### Update the Template

Update the profile template with the command:

``
ansible-playbook create-template.yml -i inventory.yml -e profile=Ubuntu-22.04-Minimal-30GB
``

### Commit the Changes

Commit the changes made manually during the first step and automatically during the second step.

### Build the Image

If this is a new image template, the image definition must be created first:

``
ansible-playbook create-definition.yml -i inventory.yml -e profile=Ubuntu-22.04-Minimal-30GB
``

Build the image defined by the template with the command:

``
ansible-playbook create-image.yml -i inventory.yml -e profile=Ubuntu-22.04-Minimal-30GB
``

> NOTE: This step is expected to run for more than an hour. Come back and check on it later.

### Deploy the Image

Retrieve the list of image versions with the command:

``
ansible-playbook -i inventory.yml list-image-versions.yml -e profile=Ubuntu-22.04-Minimal-30GB
``

Once the image has been built, it can be tested with the command:

```
ansible-playbook create-vm.yml -i inventory.yml -e profile=Ubuntu-22.04-Minimal-30GB -e image_version=0.25610.38691
```

Once the image has been built, update and deploy the appropriate scale sets in the `bicep` directory.
