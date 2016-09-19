#!/bin/bash
# ------------------------------------------------------------------------
#
# Copyright 2016 WSO2, Inc. (http://wso2.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License

# ------------------------------------------------------------------------
set -e
self_path=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${self_path}/scripts/base.sh"

declare -A product_code_to_name_map=( [esb]=wso2esb [apim]=wso2am [is]=wso2is [das]=wso2das )
declare -A product_name_to_module_repo_map=( [wso2esb]=puppet-esb [wso2am]=puppet-apim [wso2is]=puppet-is [wso2das]=puppet-das )

# Show usage and exit
function showUsageAndExit() {
  echoError "Insufficient or invalid options provided!"
  echo
  echoBold "Usage: ./setup.sh -p [product-name]"
  echo

  echoBold "Options:"
  echo
  echo -en "  -p\t"
  echo "[REQUIRED] Comma separated list of product codes. [as,esb,bps,brs,greg,is,apim][all]"
  echo

  echoBold "Ex: ./setup.sh -p as "
  echoBold "Ex: ./setup.sh -p as,esb,bps "
  echoBold "Ex: ./setup.sh -p all "
  echo
  exit 1
}

function validatePuppetHome() {
  if [ ! -d "${1}" ]; then
    echoError "Invalid path provided for [PUPPET_HOME] ${1}"
    exit 1
  fi
  export PUPPET_HOME=${1}
  if [ "$(ls -A ${PUPPET_HOME})" ]; then
    echoDim "[PUPPET_HOME] $PUPPET_HOME directory is not empty. Continuing..."
  fi
}

# Setup Puppet module for given wso2 product
# $1 - Puppet module name (equivalent to product name)
# $2 - Puppet module GitHub repo name
function setupModule() {
  echoInfo "Setting up ${1} Puppet module..."
  if [ -d "${PUPPET_HOME}/modules/${1}" ]; then
    echoWarn "${PUPPET_HOME}/modules/${1} directory exists. Skipping..."
    return
  fi

  # clone repository
  puppet_git_url="https://github.com/wso2/${2}"
  curl -s --head ${puppet_git_url} | head -n 1 | grep "HTTP/1.[01] [23].." > /dev/null
  if [ $? -ne 0 ]; then
    echoError "[URL] ${puppet_git_url} is not reachable."
    echoError "Failed to setup PUPPET_HOME"
    exit 1
  fi
  git clone ${puppet_git_url} "${PUPPET_HOME}/modules/${1}"
  # TODO: Checkout released product version tag.

  echoInfo "Creating symlink for Hiera data..."
  if [[ ${1} == "wso2base" ]];then
    ln -sf  ${PUPPET_HOME}/modules/${1}/hieradata/dev/wso2/common.yaml ${PUPPET_HOME}/hieradata/dev/wso2/
  else
    ln -sf  ${PUPPET_HOME}/modules/${1}/hieradata/dev/wso2/${1} ${PUPPET_HOME}/hieradata/dev/wso2/
  fi
  echoSuccess "Successfully installed ${1} puppet module."
}

while getopts :p: FLAG; do
  case ${FLAG} in
    p)
      product_code=$OPTARG
      ;;
    \?)
      showUsageAndExit
      ;;
  esac
done

if [[ -z ${product_code} ]]; then
  showUsageAndExit
fi

if [[ ${product_code} != "all" && ${product_code_to_name_map[$product_code]+_} == "" ]]; then
  echoError "Entered product code ${product_code} is not supported"
  showUsageAndExit
fi

if [ -z "$PUPPET_HOME" ]; then
  echoWarn "PUPPET_HOME is not set as an environment variable, prompting for input..."
  askBold "Enter directory path for PUPPET_HOME: "
  read -r puppet_home_v
  PUPPET_HOME=${puppet_home_v}
fi

validatePuppetHome ${PUPPET_HOME}
echoInfo "Setting up [PUPPET_HOME] ${PUPPET_HOME}..."

# Copy Hiera configuration file
cp ${self_path}/hiera.yaml ${PUPPET_HOME}

# Create symlink for manifest/site.pp
echoInfo "Creating symlink for site.pp..."
ln -sf ${self_path}/manifests ${PUPPET_HOME}/

# Create folder structure
mkdir -p ${PUPPET_HOME}/files/packs
mkdir -p ${PUPPET_HOME}/hieradata/dev/wso2
mkdir -p ${PUPPET_HOME}/modules

# Setup wso2base Puppet module
setupModule "wso2base" "puppet-base"

# Setup Puppet modules for specified products
if [[ ${product_code} == "all" ]]; then
  for K in "${!product_code_to_name_map[@]}"; do
    product_name_array=("$product_name_array" ${K})
  done
else
  product_name_array=(${product_code_to_name_map[$product_code]})
fi

for product_name in "${product_name_array[@]}"; do
  setupModule ${product_name} "${product_name_to_module_repo_map[$product_name]}"
done

echoInfo "Setup completed successfully. Please copy relevant distributions to Puppet file bucket."