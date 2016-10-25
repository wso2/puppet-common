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

# Applications server node definitions
node /as\.dev\.wso2\.org/ {
  if $::use_hieradata == "true" {
    require wso2base::java
    hiera_include('classes')

  } else {
    class { '::wso2base::java': } -> class { '::wso2as': }
  }
}

# Enterprise Service Bus node definitions
node /esb\.dev\.wso2\.org/ {
  if $::use_hieradata == "true" {
    require wso2base::java
    hiera_include('classes')

  } else {
    class { '::wso2base::java': } -> class { '::wso2esb': }
  }
}

# Business Rule Server node definitions
node /brs\.dev\.wso2\.org/ {
  if $::use_hieradata == "true" {
    require wso2base::java
    hiera_include('classes')

  } else {
    class { '::wso2base::java': } -> class { '::wso2brs': }
  }
}

# Data Services Server node deifintions
node /dss\.dev\.wso2\.org/ {
  if $::use_hieradata == "true" {
    require wso2base::java
    hiera_include('classes')

  } else {
    class { '::wso2base::java': } -> class { '::wso2dss': }
  }
}

# API Manager node deifintions
node /am\.dev\.wso2\.org/ {
  if $::use_hieradata == "true" {
    require wso2base::java
    hiera_include('classes')

  } else {
    class { '::wso2base::java': } -> class { '::wso2am': }
  }
}

node /km\.dev\.wso2\.org/ {
  if $::use_hieradata == "true" {
    require wso2base::java
    hiera_include('classes')

  } else {
    class { '::wso2base::java': } -> class { '::wso2am': }
  }
}

node /store\.dev\.wso2\.org/ {
  if $::use_hieradata == "true" {
    require wso2base::java
    hiera_include('classes')

  } else {
    class { '::wso2base::java': } -> class { '::wso2am': }
  }
}

node /pub\.dev\.wso2\.org/ {
  if $::use_hieradata == "true" {
    require wso2base::java
    hiera_include('classes')

  } else {
    class { '::wso2base::java': } -> class { '::wso2am': }
  }
}

node /gw\.dev\.wso2\.org/ {
  if $::use_hieradata == "true" {
    require wso2base::java
    hiera_include('classes')

  } else {
    class { '::wso2base::java': } -> class { '::wso2am': }
  }
}

node /mgt\.gw\.dev\.wso2\.org/ {
  if $::use_hieradata == "true" {
    require wso2base::java
    hiera_include('classes')

  } else {
    class { '::wso2base::java': } -> class { '::wso2am': }
  }
}

# Default node definition (i.e. if the hostname does not match this section will be executed)
node "default" {
  if $::use_hieradata == "true" {
    require wso2base::java
    hiera_include('classes')

  } else {
    class { '::wso2base::java': } -> class { "::${::product_name}": }
  }
}
