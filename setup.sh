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
  echo "[REQUIRED] Product code. [as,esb,bps,brs,greg,is,apim]"
  echo -en "  -t\t"
  echo "[REQUIRED] Product deployment pattern. [pattern_01,pattern_02] "
  echo -en "  -v\t"
  echo "[OPTIONAL] Product version"
  echo

  echoBold "Ex: ./setup.sh -p as -t pattern_01"
  echoBold "Ex: ./setup.sh -p esb -t pattern_01 -v 1.10.0"
  echo
  exit 1
}

function validatePuppetHome () {
    if [ -z "$PUPPET_HOME" ]; then
        echoError "PUPPET_HOME variable could not be found! Set PUPPET_HOME environment variable pointing to local folder"
        exit 1
    fi
    if [ "$(ls -A $PUPPET_HOME)" ]; then
        echoDim "[PUPPET_HOME] $PUPPET_HOME directory is not empty. Continuing ..."
    fi
}

function setupModule () {

    echoInfo "Setting up wso2${1} puppet module ..."
    if [ -d wso2${1} ]; then
        echoWarn "${PUPPET_HOME}/modules/wso2-${1} directory is not empty."
        echoWarn "Not cloning ..."
        return
    fi
    curl -s --head https://github.com/wso2/puppet-${1} | head -n 1 | grep "HTTP/1.[01] [23].." > /dev/null
    if [ $? -ne 0 ]; then
        echoError "URL [https://github.com/wso2/puppet-${1}] is not reachable."
        exit 1
    fi
    git clone https://github.com/wso2/puppet-${1}
    mv puppet-${1} wso2${1}

    echoInfo "Creating symlink for hieradata ..."
    current_dir=`pwd`
    # creating symlink for hieradata
    if [ $1 == "base" ];then
        ln -s  ${current_dir}/wso2${1}/hieradata/dev/wso2/common.yaml ../hieradata/dev/wso2/
        return
    fi
    ln -s  ${current_dir}/wso2${1}/hieradata/dev/wso2/wso2${1}/${2} ../hieradata/dev/wso2/
}

while getopts :p:v:t: FLAG; do
  case $FLAG in
    p)
      product=$OPTARG
      ;;
    t)
      pattern=$OPTARG
      ;;
    v)
      version=$OPTARG
      ;;
    \?)
      showUsageAndExit
      ;;
  esac
done

if [[ -z ${product} ]] || [[ -z ${pattern} ]]; then
  showUsageAndExit
fi

validatePuppetHome
echoInfo "Starting setup ..."
pushd ${PUPPET_HOME} > /dev/null
cp ${self_path}/hiera.yaml .
cp -a ${self_path}/manifests .

mkdir -p hieradata/dev/wso2
mkdir -p modules
cd modules
setupModule "base"
echoSuccess "wso2base puppet module installed."
setupModule ${product} ${pattern}
echoSuccess "wso2${product} puppet module installed."


