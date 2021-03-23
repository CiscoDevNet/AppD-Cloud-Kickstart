# Compute Instance

This module is used to create compute instances (and only compute instances) using
[google_compute_instance_from_template](https://www.terraform.io/docs/providers/google/r/compute_instance_from_template.html), with no instance groups.

The inputs have been modified from the original project [here](https://github.com/terraform-google-modules/terraform-google-vm/tree/master/modules/compute_instance)
to allow for the use of an input zone and a numerical suffix which can be appended to the instance name. Additional outputs have also been added to
display instance information, such as the private and public IP addresses.

## Usage

See the [simple](https://github.com/terraform-google-modules/terraform-google-vm/tree/master/examples/compute_instance/simple) for a usage example.

## Testing


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_config | Access configurations, i.e. IPs via which the VM instance can be accessed via the Internet. | <pre>list(object({<br>    nat_ip       = string<br>    network_tier = string<br>  }))</pre> | `[]` | no |
| hostname | Hostname of instances | `string` | `""` | no |
| instance\_template | Instance template self\_link used to create compute instances | `any` | n/a | yes |
| network | Network to deploy to. Only one of network or subnetwork should be specified. | `string` | `""` | no |
| num\_instances | Number of instances to create. This value is ignored if static\_ips is provided. | `string` | `"1"` | no |
| use\_num\_suffix | Always append numerical suffix to instance name, even if num\_instances is 1. | bool | `false` | no |
| region | Region where the instances should be created. | `string` | `null` | no |
| static\_ips | List of static IPs for VM instances | `list(string)` | `[]` | no |
| subnetwork | Subnet to deploy to. Only one of network or subnetwork should be specified. | `string` | `""` | no |
| subnetwork\_project | The project that subnetwork belongs to | `string` | `""` | no |
| zone | Zone where the instances should be created. | string | `""` | no |
| owner | Name of the owner of the deployment. | string | `"terraform-builder"` | no |
| event | Name of the event for which this deployment was created. | string | `"appd-cloud-platform-ha-deployment"` | no |

## Outputs

| Name | Description |
|------|-------------|
| available\_zones | List of available zones in region |
| instances\_self\_links | List of self-links for compute instances |
| id | an identifier for the resource with format: `projects/{{project}}/zones/{{zone}}/instances/{{name}}` |
| instance\_id | The server-assigned unique identifier of this instance |
| network\_ip | The internal ip address of the instance, either manually or dynamically assigned |
| nat\_ip | If the instance has an access config, either the given external ip (in the `nat_ip` field) or the ephemeral (generated) ip (if you didn't provide one) |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
