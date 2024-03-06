terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.94"
    }
  }

  required_version = ">= 1.5"
}

resource "random_password" "admin_password" {
  length  = 16
  special = false
}

variable "azurerm_resource_group_name" {
  description = "The name of the resource group in which to create the resources."
  default     = "Honeypots"
  type        = string
}

variable "location" {
  description = "The location/region where the resources will be created."
  default     = "northeurope"
  type        = string
}

variable "admin_username" {
  description = "The username for the Virtual Machine."
  default     = "ubuntu"
  type        = string
}

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "honeypots" {
  name     = var.azurerm_resource_group_name
  location = var.location
}


resource "azurerm_virtual_network" "vnet" {
  name                = "honeypot-vnet"
  location            = azurerm_resource_group.honeypots.location
  resource_group_name = azurerm_resource_group.honeypots.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = "Honeypots"
  }

  depends_on = [azurerm_resource_group.honeypots]
}


resource "azurerm_subnet" "subnet" {
  name                 = "honeypot-subnet"
  resource_group_name  = azurerm_resource_group.honeypots.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "publicip" {
  name                = "honeypot-public-ip"
  location            = azurerm_resource_group.honeypots.location
  resource_group_name = azurerm_resource_group.honeypots.name
  allocation_method   = "Static"
}

resource "azurerm_network_security_group" "nsg" {
  name                = "honeypot-nsg"
  location            = azurerm_resource_group.honeypots.location
  resource_group_name = azurerm_resource_group.honeypots.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "nic" {
  name                = "honeypot-nic"
  location            = azurerm_resource_group.honeypots.location
  resource_group_name = azurerm_resource_group.honeypots.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}

resource "azurerm_network_interface_security_group_association" "nic_grp" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

data "azurerm_image" "cowrie-image" {
  name                = "cowrie-server"
  resource_group_name = azurerm_resource_group.honeypots.name
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                            = "honeypot-vm"
  location                        = azurerm_resource_group.honeypots.location
  resource_group_name             = azurerm_resource_group.honeypots.name
  network_interface_ids           = [azurerm_network_interface.nic.id]
  size                            = "Standard_DC1s_v2"
  admin_username                  = var.admin_username
  admin_password                  = random_password.admin_password.result
  computer_name                   = "honeypot-vm"
  disable_password_authentication = false
  eviction_policy                 = "Deallocate"
  priority                        = "Spot"
  source_image_id                 = data.azurerm_image.cowrie-image.id
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}
