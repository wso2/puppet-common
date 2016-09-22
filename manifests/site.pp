# ------------------------------------------------------------------------------
#
# Copyright (c) 2016, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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
# limitations under the License.
#
# ------------------------------------------------------------------------------

node /as\.dev\.wso2\.org/ {
  if $::use_hieradata == "true" {
    require wso2base::java
    hiera_include('classes')

  } else {
    class { '::wso2base::java': } -> class { '::wso2as': }
  }
}

node /esb\.dev\.wso2\.org/ {
  if $::use_hieradata == "true" {
    require wso2base::java
    hiera_include('classes')

  } else {
    class { '::wso2base::java': } -> class { '::wso2esb': }
  }
}

node /brs\.dev\.wso2\.org/ {
  if $::use_hieradata == "true" {
    require wso2base::java
    hiera_include('classes')

  } else {
    class { '::wso2base::java': } -> class { '::wso2brs': }
  }
}

node /dss\.dev\.wso2\.org/ {
  if $::use_hieradata == "true" {
    require wso2base::java
    hiera_include('classes')

  } else {
    class { '::wso2base::java': } -> class { '::wso2dss': }
  }
}