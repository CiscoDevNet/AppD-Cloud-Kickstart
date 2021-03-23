/**
 * Copyright 2018 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

variable "network" {
  description = "Network to deploy to. Only one of network or subnetwork should be specified."
  default     = ""
}

variable "subnetwork" {
  description = "Subnet to deploy to. Only one of network or subnetwork should be specified."
  default     = ""
}

variable "subnetwork_project" {
  description = "The project that subnetwork belongs to"
  default     = ""
}

variable "hostname" {
  description = "Hostname of instances"
  default     = ""
}

variable "static_ips" {
  type        = list(string)
  description = "List of static IPs for VM instances"
  default     = []
}

variable "access_config" {
  description = "Access configurations, i.e. IPs via which the VM instance can be accessed via the Internet."
  type = list(object({
    nat_ip       = string
    network_tier = string
  }))
  default = []
}

variable "num_instances" {
  description = "Number of instances to create. This value is ignored if static_ips is provided."
  default     = "1"
}

variable "use_num_suffix" {
  description = "Always append numerical suffix to instance name, even if instance_count is 1."
  type        = bool
  default     = false
}

variable "instance_template" {
  description = "Instance template self_link used to create compute instances"
}

variable "region" {
  type        = string
  description = "Region where the instances should be created."
  default     = null
}

variable "zone" {
  description = "Zone where the instances should be created."
  type        = string
  default     = ""
}

variable "owner" {
  description = "Name of the owner of the deployment."
  type        = string
  default     = "terraform-builder"
}

variable "event" {
  description = "Name of the event for which this deployment was created."
  type        = string
  default     = "appd-cloud-platform-ha-deployment"
}

variable "labels" {
  type        = map(string)
  description = "Labels, provided as a map"
  default     = {}
}
