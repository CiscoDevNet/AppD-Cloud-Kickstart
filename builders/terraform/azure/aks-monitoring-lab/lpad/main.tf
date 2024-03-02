# Providers ----------------------------------------------------------------------------------------
provider "azurerm" {
  features {}
}

# Locals -------------------------------------------------------------------------------------------
locals {
  # format current date for convenience.
  current_date = formatdate("YYYY-MM-DD", timestamp())

  # create range of formatted lab numbers.
  lab_for_each = toset([ for i in range(var.lab_start_number, var.lab_count + var.lab_start_number) : format("%02d", i) ])

  # create vm source address prefixes list without duplicates.
  vm_source_address_prefixes = distinct(concat(var.azurerm_source_address_prefixes, var.cisco_source_address_prefixes))

  # define resource names here to ensure standardized naming conventions.
  vnet_name                    = "${var.resource_name_prefix}-${lower(random_string.suffix.result)}-vnet"
  subnet_name                  = "${var.resource_name_prefix}-${lower(random_string.suffix.result)}-subnet"
  network_security_group_name  = "${var.resource_name_prefix}-${lower(random_string.suffix.result)}-nsg"
  security_rule_allow_icmp     = "${var.resource_name_prefix}-${lower(random_string.suffix.result)}-security-rule-allow-icmp"
  security_rule_allow_internal = "${var.resource_name_prefix}-${lower(random_string.suffix.result)}-security-rule-allow-internal"
  security_rule_allow_ssh      = "${var.resource_name_prefix}-${lower(random_string.suffix.result)}-security-rule-allow-ssh"
  security_rule_allow_lpad     = "${var.resource_name_prefix}-${lower(random_string.suffix.result)}-security-rule-allow-lpad"
}

# Data Sources -------------------------------------------------------------------------------------
data "azurerm_resource_group" "cloud_workshop" {
  name     = var.azurerm_workshop_resource_group_name
}

data "azurerm_shared_image_version" "lpad" {
  name                = var.azurerm_shared_image_version
  image_name          = var.azurerm_shared_image_definition
  gallery_name        = var.azurerm_shared_image_gallery
  resource_group_name = var.azurerm_images_resource_group_name
}

# Modules ------------------------------------------------------------------------------------------

# Resources ----------------------------------------------------------------------------------------
resource "random_string" "suffix" {
  length  = 5
  special = false
}

resource "azurerm_virtual_network" "vnet" {
  name                = local.vnet_name
  address_space       = ["10.0.0.0/16"]
  resource_group_name = data.azurerm_resource_group.cloud_workshop.name
  location            = data.azurerm_resource_group.cloud_workshop.location
  tags                = var.resource_tags
}

resource "azurerm_subnet" "subnet" {
  name                 = local.subnet_name
  resource_group_name  = data.azurerm_resource_group.cloud_workshop.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = local.network_security_group_name
  resource_group_name = data.azurerm_resource_group.cloud_workshop.name
  location            = data.azurerm_resource_group.cloud_workshop.location
  tags                = var.resource_tags
}

resource "azurerm_network_security_rule" "allow_icmp" {
  name                        = local.security_rule_allow_icmp
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Icmp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefixes     = var.azurerm_source_address_prefixes
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.cloud_workshop.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "allow_internal" {
  name                        = local.security_rule_allow_internal
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefixes     = ["10.0.1.0/24"]
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.cloud_workshop.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = local.security_rule_allow_ssh
  priority                    = 102
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefixes     = var.azurerm_source_address_prefixes
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.cloud_workshop.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "allow_lpad" {
  name                        = local.security_rule_allow_lpad
  priority                    = 103
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["80", "443", "8080"]
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.cloud_workshop.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_public_ip" "lpad" {
  for_each = local.lab_for_each
  name     = var.lab_count > 1 || var.lab_use_num_suffix ? "${var.resource_name_prefix}-${each.key}-${lower(random_string.suffix.result)}-public-ip" : "${var.resource_name_prefix}-${lower(random_string.suffix.result)}-public-ip"

  resource_group_name     = data.azurerm_resource_group.cloud_workshop.name
  location                = data.azurerm_resource_group.cloud_workshop.location
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = var.azurerm_lab_tcp_idle_timeout
  tags                    = var.resource_tags
}

resource "azurerm_network_interface" "lpad" {
  for_each = local.lab_for_each
  name     = var.lab_count > 1 || var.lab_use_num_suffix ? "${var.resource_name_prefix}-${each.key}-${lower(random_string.suffix.result)}-network-interface" : "${var.resource_name_prefix}-${lower(random_string.suffix.result)}-network-interface"

  resource_group_name = data.azurerm_resource_group.cloud_workshop.name
  location            = data.azurerm_resource_group.cloud_workshop.location

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.lpad[each.key].id
  }

  tags = var.resource_tags
}

resource "azurerm_network_interface_security_group_association" "lpad" {
  for_each = local.lab_for_each

  network_interface_id      = azurerm_network_interface.lpad[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_linux_virtual_machine" "lpad" {
  for_each = local.lab_for_each
  name     = var.lab_count > 1 || var.lab_use_num_suffix ? "${var.resource_name_prefix}-${each.key}-${lower(random_string.suffix.result)}-vm" : "${var.resource_name_prefix}-${lower(random_string.suffix.result)}-vm"

  resource_group_name   = data.azurerm_resource_group.cloud_workshop.name
  location              = data.azurerm_resource_group.cloud_workshop.location
  computer_name         = var.lab_count > 1 || var.lab_use_num_suffix ? "${var.azurerm_lpad_vm_hostname_prefix}-${each.key}-vm" : "${var.azurerm_lpad_vm_hostname_prefix}-vm"
  size                  = var.azurerm_vm_size
  admin_username        = var.azurerm_ssh_username
  network_interface_ids = [azurerm_network_interface.lpad[each.key].id]

  custom_data = base64encode(templatefile("${path.module}/templates/user-data-sh.tmpl", {
    azurerm_ssh_username       = var.azurerm_ssh_username,
    azurerm_vm_hostname_prefix = var.azurerm_lpad_vm_hostname_prefix,
    azurerm_vm_domain          = "",
    azurerm_use_num_suffix     = var.lab_use_num_suffix
  }))

  admin_ssh_key {
    username   = var.azurerm_ssh_username
    public_key = file(var.lab_ssh_pub_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.azurerm_storage_account_type
  }

  # some azure marketplace images require a plan block.
  dynamic "plan" {
    for_each = var.include_azure_marketplace_image_plan ? [1] : []
    content {
      publisher = var.azure_marketplace_image_publisher
      product   = var.azure_marketplace_image_product
      name      = var.azure_marketplace_image_name
    }
  }

  source_image_id = data.azurerm_shared_image_version.lpad.id
  tags            = var.resource_tags
}

# create ansible trigger to generate inventory and helper files. -----------------------------------
resource "null_resource" "ansible_trigger" {
  # fire the ansible trigger when any ec2 instance requires re-provisioning.
  triggers = {
    compute_instance_ids = join(",", flatten([for vm in azurerm_linux_virtual_machine.lpad : vm.id]))
  }

  # execute the following 'local-exec' provisioners each time the trigger is invoked.
  # generate the ansible azure hosts inventory.
  provisioner "local-exec" {
    working_dir = "."
    command     = <<EOD
cat <<EOF > azure_hosts.inventory
[lpad_vm]
${join("\n", flatten([for vm in azurerm_linux_virtual_machine.lpad : vm.public_ip_address]))}
EOF
EOD
  }
}
