# Deploy WSO2 Products with Puppet using Vagrant

This guide walks through the steps needed for deploying WSO2 products using Vagrant with VirtualBox as the provider.
Puppet will be used as the provisioning method in Vagrant and Hiera as the configuration data store.


## Pre-requisites

 * **[Vagrant](https://www.vagrantup.com)**
 * **[Virtualbox](https://www.virtualbox.org)** Vagrant hypervisor


## How to Use

1. Create server configuration file:

    Rename `config.yaml.sample` to `config.yaml` and update the `/servers` section with required values. You can add more instances by adding more entries to `/servers` array. You can pass facters to Vagrant nodes through `/servers/*/facters` array.

    Additionally, you can copy a sample `config.yaml` file from the `vagrant-samples` folder found in puppet-<product> repository for quickly running a product on Vagrant.

2. Download and copy Oracle JDK `1.7_80` distribution to the following path:

    ````
    <PUPPET_HOME>/modules/wso2base/files/jdk-7u80-linux-x64.tar.gz
    ````

3. Download and copy required WSO2 product distributions to each Puppet module under `files` folder:

    ````
    <PUPPET_HOME>/modules/wso2esb/files
    <PUPPET_HOME>/modules/wso2is/files
    ````

4. Optionally update `<PUPPET_HOME>/hieradata` with required product configurations. `default` profile every product can be run on Vagrant without any changes to the Hiera data.

5. Execute the following command to start the VMs:

    ````
    vagrant up
    ````