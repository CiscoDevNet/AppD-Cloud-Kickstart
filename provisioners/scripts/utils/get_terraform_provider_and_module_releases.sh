#!/bin/sh
echo "--------------------------------------"
echo "Terraform Provider and Module Releases"
echo "--------------------------------------"
echo "AWS Providers:"
curl --silent --user ed-barberis:380968adf99404ff071b4839f6960a5da72449c4 https://api.github.com/repos/hashicorp/terraform-provider-aws/releases/latest | jq '. | {tag_name: .tag_name, html_url: .html_url}'
curl --silent --user ed-barberis:380968adf99404ff071b4839f6960a5da72449c4 https://api.github.com/repos/terraform-aws-modules/terraform-aws-ec2-instance/tags | jq '.[0] | {name: .name, tarball_url: .tarball_url}'
curl --silent --user ed-barberis:380968adf99404ff071b4839f6960a5da72449c4 https://api.github.com/repos/terraform-aws-modules/terraform-aws-security-group/tags | jq '.[0] | {name: .name, tarball_url: .tarball_url}'
curl --silent --user ed-barberis:380968adf99404ff071b4839f6960a5da72449c4 https://api.github.com/repos/terraform-aws-modules/terraform-aws-vpc/tags | jq '.[0] | {name: .name, tarball_url: .tarball_url}'
curl --silent --user ed-barberis:380968adf99404ff071b4839f6960a5da72449c4 https://api.github.com/repos/terraform-aws-modules/terraform-aws-eks/releases/latest | jq '. | {tag_name: .tag_name, html_url: .html_url}'
curl --silent --user ed-barberis:380968adf99404ff071b4839f6960a5da72449c4 https://api.github.com/repos/terraform-aws-modules/terraform-aws-elb/tags | jq '.[0] | {name: .name, tarball_url: .tarball_url}'
echo ""

echo "Azure Providers:"
curl --silent --user ed-barberis:380968adf99404ff071b4839f6960a5da72449c4 https://api.github.com/repos/terraform-providers/terraform-provider-azurerm/releases/latest | jq '. | {tag_name: .tag_name, html_url: .html_url}'
echo ""

echo "Google Providers:"
curl --silent --user ed-barberis:380968adf99404ff071b4839f6960a5da72449c4 https://api.github.com/repos/hashicorp/terraform-provider-google/releases/latest | jq '. | {tag_name: .tag_name, html_url: .html_url}'
curl --silent --user ed-barberis:380968adf99404ff071b4839f6960a5da72449c4 https://api.github.com/repos/terraform-google-modules/terraform-google-vm/releases/latest | jq '. | {tag_name: .tag_name, html_url: .html_url}'
curl --silent --user ed-barberis:380968adf99404ff071b4839f6960a5da72449c4 https://api.github.com/repos/terraform-google-modules/terraform-google-network/releases/latest | jq '. | {tag_name: .tag_name, html_url: .html_url}'
echo ""

echo "Terraform Providers:"
curl --silent --user ed-barberis:380968adf99404ff071b4839f6960a5da72449c4 https://api.github.com/repos/hashicorp/terraform/releases/latest | jq '. | {tag_name: .tag_name, html_url: .html_url}'
curl --silent --user ed-barberis:380968adf99404ff071b4839f6960a5da72449c4 https://api.github.com/repos/hashicorp/terraform-provider-kubernetes/tags | jq '.[0] | {name: .name, tarball_url: .tarball_url}'
curl --silent --user ed-barberis:380968adf99404ff071b4839f6960a5da72449c4 https://api.github.com/repos/hashicorp/terraform-provider-local/tags | jq '.[0] | {name: .name, tarball_url: .tarball_url}'
curl --silent --user ed-barberis:380968adf99404ff071b4839f6960a5da72449c4 https://api.github.com/repos/hashicorp/terraform-provider-null/tags | jq '.[0] | {name: .name, tarball_url: .tarball_url}'
curl --silent --user ed-barberis:380968adf99404ff071b4839f6960a5da72449c4 https://api.github.com/repos/hashicorp/terraform-provider-random/tags | jq '.[0] | {name: .name, tarball_url: .tarball_url}'
curl --silent --user ed-barberis:380968adf99404ff071b4839f6960a5da72449c4 https://api.github.com/repos/hashicorp/terraform-provider-template/tags | jq '.[0] | {name: .name, tarball_url: .tarball_url}'
