# WSO2 Puppet Common

WSO2 Puppet Common repository provides files required for setting up a Puppet environment:

- [manifests/site.pp](manifests/site.pp): Puppet site manifest
- [scripts/base.sh](scripts/base.sh): Base bash script file which provides utility bash methods.
- [setup.sh](setup.sh): The setup bash script for setting up a puppet environment for development work.
- [vagrant](vagrant) A vagrant script for testing Puppet modules using VirtualBox.

## Getting Started

Execute setup.sh to prepare a Puppet environment:

```bash
Usage: ./setup.sh -p [product-name] -l [platform]

Options:

  -p	[REQUIRED] Comma separated list of product codes. [esb,is,apim,das][all]
  -l	[OPTIONAL] Platform to setup Hiera data. If none given 'default' platform will be taken
  -v	[OPTIONAL] Product version. If none given latest version will be taken. Multiple products not supported.
  -t    [OPTIONAL] Product-puppet module release tag. Checkouts the tag into a detached HEAD state.

Ex: ./setup.sh -p esb
Ex: ./setup.sh -p esb -v 4.9.0
Ex: ./setup.sh -p esb,apim -l kubernetes
Ex: ./setup.sh -p apim -t v2.1.0
Ex: ./setup.sh -p all
```
Finally go to the puppet-base module and checkout the compatible version of puppet-base module with the
product-module version.

### Required Custom Facts

Following custom Facts are required for the WSO2 Puppet modules to run.

```yaml
product_name: Product name as defined in the product Puppet module
product_version: Produce version
product_profile: Product profile
environment: Puppet environment
platform: The platform to use. ex: default, kubernetes, mesos
use_hieradata: Set to true to use Hiera as the data backend
install_java: Set to true to install the JDK during the Puppet run.
pattern: Product pattern as defined in the product Puppet module.
```

For example, for WSO2 API Manager pattern-0, the following set of Facts can be set.

```yaml
product_name: wso2am_runtime
product_version: 2.1.0
product_profile: default
environment: dev
platform: default
use_hieradata: false
install_java: true
pattern: pattern-0
```
