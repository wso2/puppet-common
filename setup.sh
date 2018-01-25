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

function getProductName() {
  case ${1} in
    esb)
      product_name="wso2esb"
      ;;
    apim)
      product_name="wso2am"
      ;;
    is)
      product_name="wso2is"
      ;;
    das)
      product_name="wso2das"
      ;;
    cep)
      product_name="wso2cep"
      ;;
    iot)
      product_name="wso2iot"
      ;;
    \?)
      product_name=""
      ;;
  esac
}

# Show usage and exit
function showUsageAndExit() {
  echoError "Insufficient or invalid options provided!"
  echo
  echoBold "Usage: ./setup.sh -p [product-name] -l [platform]"
  echo

  echoBold "Options:"
  echo
  echo -en "  -p\t"
  echo "[REQUIRED] Comma separated list of product codes. [esb,is,apim,das][all]"
  echo -en "  -l\t"
  echo "[OPTIONAL] Platform to setup Hiera data. If none given 'default' platform will be taken"
  echo -en "  -v\t"
  echo "[OPTIONAL] Product version. The version related branch will be checked out. If none given, latest version will
   be taken. Multiple products not supported."
  echo -en "  -t\t"
  echo "[OPTIONAL] Product-puppet module release tag. Checkouts the tag into a detached HEAD state"
  echo

  echoBold "Ex: ./setup.sh -p esb "
  echoBold "Ex: ./setup.sh -p esb -v 4.9.0 "
  echoBold "Ex: ./setup.sh -p esb,apim -l kubernetes"
  echoBold "Ex: ./setup.sh -p all "
  echoBold "Ex: ./setup.sh -p apim -t v2.1.0"
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

# To checkout the git branch and switch between branches if it exists
# $1 - Puppet module name (equivalent to product name)
# $2 - product version (branch related to the given version will be checked out)
function checkoutBranch() {
  pushd ${PUPPET_HOME}/modules/${1}
    if [[ ${2} == "latest" ]]; then
      if [[ `git branch --list master` ]]; then
        if [[ `git symbolic-ref --short -q HEAD` != "master" ]]; then
          echo "checking out master..."
          git checkout master
        fi
      else
        echo "creating branch master"
        git checkout -b master
      fi
    else
      if [[ `git branch --list v${2}` ]]; then
        if [[ `git symbolic-ref --short -q HEAD` != "${2}" ]]; then
          echo "checking out branch ${2}"
          git checkout v${2}
        fi
      else
        echo "creating branch ${2}"
        git checkout -b v${2} origin/v${2} || echoWarn "Puppet module for ${1} ${2} is not available"
      fi
    fi
  popd
}

# Checkout the release tag to a new branch
# $1 - Puppet module name (equivalent to product name)
# $2 - product release tag
function checkoutTag(){
  pushd ${PUPPET_HOME}/modules/${1}
    if [[ -n ${2} ]]; then
      if [[ `git tag -l ${2}` == ${2} ]]; then
        echoInfo "Checking out tag ${2} ..."
        git checkout tags/${2}
      else
        echoError "Specified tag '${2}' does not exist for puppet module repository '${1}'";
      fi
    fi
  popd
}

# Setup Puppet module for given wso2 product
# $1 - Puppet module name (equivalent to product name)
# $2 - product code
# $3 - platform
# $4 - product version
# $5 - Release tag of the product puppet module
function setupModule() {
  echoInfo "Setting up ${1} Puppet module for ${3} platform..."
  if [ -d "${PUPPET_HOME}/modules/${1}" ]; then

    if [[ ${1} != "wso2base" ]];then
      checkoutBranch ${1} ${4}
      checkoutTag ${1} ${5}
    fi

    echoWarn "${PUPPET_HOME}/modules/${1} directory exists. Skipping..."
    return
  fi

  # clone repository
  puppet_git_url="https://github.com/wso2/puppet-${2}"
  curl -s --head ${puppet_git_url} | head -n 1 | grep "HTTP/1.[01] [23].." > /dev/null
  if [ $? -ne 0 ]; then
    echoError "[URL] ${puppet_git_url} is not reachable."
    echoError "Failed to setup PUPPET_HOME"
    exit 1
  fi

  git clone ${puppet_git_url} "${PUPPET_HOME}/modules/${1}"
  if [[ ${1} == "wso2base" ]];then
      echoInfo "Cloned wso2base module and it is in the master branch"
  fi

  if [[ ${2} == "iot" ]]; then
    mv "${PUPPET_HOME}/modules/${1}/wso2iot_core" "${PUPPET_HOME}/modules/"
    mv "${PUPPET_HOME}/modules/${1}/wso2iot_analytics" "${PUPPET_HOME}/modules/"
    mv "${PUPPET_HOME}/modules/${1}/wso2iot_broker" "${PUPPET_HOME}/modules/"

    rm -rf "${PUPPET_HOME}/modules/${1}"

    echoInfo "Creating symlink for Hiera data..."
    ln -sf  "${PUPPET_HOME}/modules/wso2iot_core/hieradata/dev/wso2/wso2iot_core" "${PUPPET_HOME}/hieradata/dev/wso2/"
    ln -sf  "${PUPPET_HOME}/modules/wso2iot_broker/hieradata/dev/wso2/wso2iot_broker" "${PUPPET_HOME}/hieradata/dev/wso2/"
    ln -sf  "${PUPPET_HOME}/modules/wso2iot_analytics/hieradata/dev/wso2/wso2iot_analytics" "${PUPPET_HOME}/hieradata/dev/wso2/"
    echoSuccess "Successfully installed ${1} puppet modules and Hiera data for ${3} platform."

    return
  fi

  if [[ ${2} == "apim" ]]; then
    checkoutBranch ${1} ${4}
    checkoutTag ${1} ${5}
    mv "${PUPPET_HOME}/modules/${1}/wso2am_runtime" "${PUPPET_HOME}/modules/"
    mv "${PUPPET_HOME}/modules/${1}/wso2am_analytics" "${PUPPET_HOME}/modules/"
    mv "${PUPPET_HOME}/modules/${1}/wso2is_prepacked" "${PUPPET_HOME}/modules/"
    rm -rf "${PUPPET_HOME}/modules/${1}"

    echoInfo "Creating symlink for Hiera data..."
    ln -sf  "${PUPPET_HOME}/modules/wso2am_runtime/hieradata/dev/wso2/wso2am_runtime" "${PUPPET_HOME}/hieradata/dev/wso2/"
    ln -sf  "${PUPPET_HOME}/modules/wso2am_analytics/hieradata/dev/wso2/wso2am_analytics" "${PUPPET_HOME}/hieradata/dev/wso2/"
    ln -sf  "${PUPPET_HOME}/modules/wso2is_prepacked/hieradata/dev/wso2/wso2is_prepacked" "${PUPPET_HOME}/hieradata/dev/wso2/"
    echoSuccess "Successfully installed ${1} puppet modules and Hiera data for ${3} platform."

    return
  fi

  if [[ ${2} == "is" ]]; then
    checkoutBranch ${1} ${4}
    checkoutTag ${1} ${5}
    mv "${PUPPET_HOME}/modules/${1}" "${PUPPET_HOME}/modules/${1}-tmp"
    mv "${PUPPET_HOME}/modules/${1}-tmp/wso2is" "${PUPPET_HOME}/modules/"
    mv "${PUPPET_HOME}/modules/${1}-tmp/wso2is_analytics" "${PUPPET_HOME}/modules/"
    rm -rf "${PUPPET_HOME}/modules/${1}-tmp"

    echoInfo "Creating symlink for Hiera data..."
    ln -sf  "${PUPPET_HOME}/modules/wso2is/hieradata/dev/wso2/wso2is" "${PUPPET_HOME}/hieradata/dev/wso2/"
    ln -sf  "${PUPPET_HOME}/modules/wso2is_analytics/hieradata/dev/wso2/wso2is_analytics" "${PUPPET_HOME}/hieradata/dev/wso2/"
    echoSuccess "Successfully installed ${1} puppet modules and Hiera data for ${3} platform."

    return
  fi

  echoInfo "Creating symlink for Hiera data..."
  if [[ ${1} == "wso2base" ]];then
    ln -sf  "${PUPPET_HOME}/modules/${1}/hieradata/dev/wso2/common.yaml" "${PUPPET_HOME}/hieradata/dev/wso2/"
    echoSuccess "Successfully installed ${1} puppet module and Hiera data for ${3} platform."
    return
  else
    checkoutBranch ${1} ${4}
    checkoutTag ${1} ${5}
  fi

  if [[ ${3} == "default" ]]; then
    ln -sf  "${PUPPET_HOME}/modules/${1}/hieradata/dev/wso2/${1}" "${PUPPET_HOME}/hieradata/dev/wso2/"
  else
    mkdir -p "${PUPPET_HOME}/${3}/"
    platform_artifacts_url="https://github.com/wso2/${3}-${2}"
    curl -s --head ${platform_artifacts_url} | head -n 1 | grep "HTTP/1.[01] [23].." > /dev/null
    if [ $? -ne 0 ]; then
      echoError "[URL] ${platform_artifacts_url} is not reachable."
      echoError "Failed to setup Hiera data for ${4} platform"
      exit 1
    fi
    git clone ${platform_artifacts_url} "${PUPPET_HOME}/${3}/${3}-${2}"
    ln -sf  "${PUPPET_HOME}/${3}/${3}-${2}/hieradata/dev/wso2/${1}" ${PUPPET_HOME}/hieradata/dev/wso2/
  fi

  echoSuccess "Successfully installed ${1} puppet module and Hiera data for ${3} platform."
}

platform='default'
while getopts :p:l:v:t: FLAG; do
  case ${FLAG} in
    p)
      product_codes=$OPTARG
      ;;
    l)
      platform=$OPTARG
      ;;
    v)
      product_version=$OPTARG
      ;;
    t)
      release_tag=$OPTARG
      ;;
    \?)
      showUsageAndExit
      ;;
  esac
done

if [[ -z ${product_codes} ]]; then
  showUsageAndExit
fi

if [[ -z ${product_version} ]]; then
  product_version="latest"
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
setupModule "wso2base" "base" "default"

# Setup Puppet modules for specified products
if [[ ${product_codes} == "all" ]]; then
  IFS=',' read -r -a product_code_array <<< "apim,cep,das,esb,is,iot"
else
  IFS=',' read -r -a product_code_array <<< "${product_codes}"
fi

for product_code in "${product_code_array[@]}"; do
  getProductName ${product_code}
  setupModule ${product_name} ${product_code} ${platform} ${product_version} ${release_tag}
done

echoInfo "Setup completed successfully. Please copy relevant distributions to Puppet file bucket."
