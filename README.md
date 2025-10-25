# azure-pipelines-test-vm

Virtual machine image builder for running ansible-test on Azure Pipelines.

## Building and Deploying a VM Image

These instructions will use the ``Ubuntu-24.04`` image in the examples.
Substitute the desired image as needed.

### Update the Image Profile

Create or update the desired image profile in the ``profiles`` directory.
Profiles are used to define how an image should be built.

### Build the Image

Build the image defined by the profile with the command:

``
ansible-playbook create-image.yml -e profile=Ubuntu-24.04
``

> NOTE: This step is expected to run for up to an hour. Come back and check on it later.

### Listing the Image Versions

Retrieve the list of image versions with the command:

``
ansible-playbook list-image-versions.yml -e profile=Ubuntu-24.04
``

### Testing the Image

If needed, an image can be tested before being deployed:

```
ansible-playbook create-vm.yml -e profile=Ubuntu-24.04 -e image_version=1.0.0
```

> NOTE: Don't forget to remove the test VM's resource group after testing is complete.

### Deploy the Image

Once the image has been built,
update and deploy the appropriate scale sets in the `bicep` directory.
