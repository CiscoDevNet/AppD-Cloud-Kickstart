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

output "instances_self_links" {
  description = "List of self-links for compute instances"
  value       = google_compute_instance_from_template.compute_instance.*.self_link
}

output "available_zones" {
  description = "List of available zones in region"
  value       = data.google_compute_zones.available.names
}

output "id" {
  description = "An identifier for the resource."
  value       = google_compute_instance_from_template.compute_instance.*.id
}

output "instance_id" {
  description = "The server-assigned unique identifier of this instance."
  value       = google_compute_instance_from_template.compute_instance.*.instance_id
}

output "network_ip" {
  description = "The private IP address assigned to the instance."
  value       = google_compute_instance_from_template.compute_instance.*.network_interface.0.network_ip
}

output "nat_ip" {
  description = "The external IP address assigned to the instance."
  value       = google_compute_instance_from_template.compute_instance.*.network_interface.0.access_config.0.nat_ip
}
