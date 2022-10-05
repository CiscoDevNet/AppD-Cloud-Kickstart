#!/bin/sh
echo "--------------------------------------"
echo "Terraform Provider and Module Releases"
echo "--------------------------------------"
echo "AWS Providers:"
curl --silent https://api.github.com/repos/hashicorp/terraform-provider-aws/releases/latest | jq '. | {name: .name, html_url: .html_url}'
curl --silent https://api.github.com/repos/terraform-aws-modules/terraform-aws-ec2-instance/tags | jq '.[0] | {name: .name, tarball_url: .tarball_url}'
curl --silent https://api.github.com/repos/terraform-aws-modules/terraform-aws-security-group/tags | jq '.[0] | {name: .name, tarball_url: .tarball_url}'
curl --silent https://api.github.com/repos/terraform-aws-modules/terraform-aws-vpc/tags | jq '.[0] | {name: .name, tarball_url: .tarball_url}'
curl --silent https://api.github.com/repos/terraform-aws-modules/terraform-aws-eks/releases/latest | jq '. | {name: .name, html_url: .html_url}'
curl --silent https://api.github.com/repos/aws-ia/terraform-aws-eks-blueprints/tags | jq '.[0] | {name: .name, tarball_url: .tarball_url}'
curl --silent https://api.github.com/repos/terraform-aws-modules/terraform-aws-elb/tags | jq '.[0] | {name: .name, tarball_url: .tarball_url}'
echo ""

echo "Azure Providers:"
curl --silent https://api.github.com/repos/hashicorp/terraform-provider-azurerm/releases/latest | jq '. | {name: .name, html_url: .html_url}'
echo ""

echo "Cisco Providers:"
curl --silent https://api.github.com/repos/CiscoDevNet/terraform-provider-intersight/releases/latest | jq '. | {name: .name, html_url: .html_url}'
curl --silent https://api.github.com/repos/terraform-cisco-modules/terraform-intersight-iks/releases/latest | jq '. | {name: .name, html_url: .html_url}'
echo ""

echo "Google Providers:"
curl --silent https://api.github.com/repos/hashicorp/terraform-provider-google/releases/latest | jq '. | {name: .name, html_url: .html_url}'
curl --silent https://api.github.com/repos/terraform-google-modules/terraform-google-vm/releases/latest | jq '. | {name: .name, html_url: .html_url}'
curl --silent https://api.github.com/repos/terraform-google-modules/terraform-google-network/releases/latest | jq '. | {name: .name, html_url: .html_url}'
curl --silent https://api.github.com/repos/terraform-google-modules/terraform-google-kubernetes-engine/releases/latest | jq '. | {name: .name, html_url: .html_url}'
echo ""

echo "Terraform Providers:"
curl --silent https://api.github.com/repos/hashicorp/terraform/releases/latest | jq '. | {name: .name, html_url: .html_url}'
curl --silent https://api.github.com/repos/hashicorp/terraform-provider-helm/tags | jq '.[0] | {name: .name, tarball_url: .tarball_url}'
curl --silent https://api.github.com/repos/hashicorp/terraform-provider-http/tags | jq '.[0] | {name: .name, tarball_url: .tarball_url}'
curl --silent https://api.github.com/repos/gavinbunney/terraform-provider-kubectl/tags | jq '.[0] | {name: .name, tarball_url: .tarball_url}'
curl --silent https://api.github.com/repos/hashicorp/terraform-provider-kubernetes/tags | jq '.[0] | {name: .name, tarball_url: .tarball_url}'
curl --silent https://api.github.com/repos/hashicorp/terraform-provider-local/tags | jq '.[0] | {name: .name, tarball_url: .tarball_url}'
curl --silent https://api.github.com/repos/hashicorp/terraform-provider-null/tags | jq '.[0] | {name: .name, tarball_url: .tarball_url}'
curl --silent https://api.github.com/repos/hashicorp/terraform-provider-random/tags | jq '.[0] | {name: .name, tarball_url: .tarball_url}'
curl --silent https://api.github.com/repos/hashicorp/terraform-provider-template/tags | jq '.[0] | {name: .name, tarball_url: .tarball_url}'
