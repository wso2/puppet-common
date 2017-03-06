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