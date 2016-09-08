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

self_path=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${self_path}/scripts/base.sh"

# Show usage and exit
function showUsageAndExit () {
  echoError "Insufficient or invalid options provided!"
  echo
  echoBold "Usage: ./setup.sh -p [product-name] -t [pattern]"
  echo

  echoBold "Options:"
  echo
  echo -en "  -p\t"
  echo "[REQUIRED] Comma seperated list of product codes. [as,esb,bps,brs,greg,is,apim][all]"
  echo

  echoBold "Ex: ./setup.sh -p as "
  echoBold "Ex: ./setup.sh -p as,esb,bps "
  echoBold "Ex: ./setup.sh -p all "
  echo
  exit 1
}

function validatePuppetHome () {
    if [ ! -d "${1}" ]; then
        echoError "Invalid path provided for [PUPPET_HOME] ${1}"
        exit 1
    fi
    export PUPPET_HOME=${1}
    if [ "$(ls -A $PUPPET_HOME)" ]; then
        echoDim "[PUPPET_HOME] $PUPPET_HOME directory is not empty. Continuing..."
    fi
}

function setupModule () {

    echoInfo "Setting up wso2${1} puppet module..."
    if [ -d wso2${1} ]; then
        echoWarn "${PUPPET_HOME}/modules/wso2-${1} directory exists."
        echoWarn "Not cloning..."
        return
    fi

    # Clone repository
    curl -s --head https://github.com/wso2/puppet-${1} | head -n 1 | grep "HTTP/1.[01] [23].." > /dev/null
    if [ $? -ne 0 ]; then
        echoError "URL [https://github.com/wso2/puppet-${1}] is not reachable."
        exit 1
    fi
    git clone https://github.com/wso2/puppet-${1}
    # TODO: Checkout released product version tag.

    mv puppet-${1} wso2${1}

    echoInfo "Creating symlink for hieradata..."
    current_dir=`pwd`
    # creating symlink for hieradata
    if [ $1 == "base" ];then
        ln -sf  ${current_dir}/wso2${1}/hieradata/dev/wso2/common.yaml ../hieradata/dev/wso2/
        echoSuccess "wso2base puppet module installed."
        return
    fi
    ln -sf  ${current_dir}/wso2${1}/hieradata/dev/wso2/wso2${1} ../hieradata/dev/wso2/
    echoSuccess "wso2${1} puppet module installed."
}

while getopts :p: FLAG; do
  case $FLAG in
    p)
      product_codes=$OPTARG
      ;;
    \?)
      showUsageAndExit
      ;;
  esac
done

if [[ -z ${product_codes} ]]; then
  showUsageAndExit
fi

if [[ ${product_codes} == "all" ]]; then
  product_codes="as,esb,bps,brs,das,cep,mb,is,apim,greg"
fi

if [ -z "$PUPPET_HOME" ]; then
  echoWarn "PUPPET_HOME variable could not be found! Set PUPPET_HOME environment variable pointing to local folder"
  askBold "Enter directory path for PUPPET_HOME : "
  read -r puppet_home_v
  PUPPET_HOME=${puppet_home_v}
fi
validatePuppetHome ${PUPPET_HOME}
echoInfo "Configuring [PUPPET_HOME] ${PUPPET_HOME}..."
echoInfo "Starting setup..."
pushd ${PUPPET_HOME} > /dev/null
cp ${self_path}/hiera.yaml .

# Create manifest/site.pp
echoInfo "Creating symlink for site.pp..."
ln -sf ${self_path}/manifests/ .

# Create folder structure
mkdir -p files/packs
mkdir -p hieradata/dev/wso2
mkdir -p modules
cd modules

# Setting up modules
setupModule "base"
IFS=',' read -r -a products_array <<< "${product_codes}"
for product in "${products_array[@]}"; do
    setupModule ${product}
done

echoInfo "Setting up puppet modules completed. Please copy relevant distributions."