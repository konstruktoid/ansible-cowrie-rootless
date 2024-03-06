packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "~> 2"
    }
  }
}

variable "client_id" {
  type        = string
  default     = env("ARM_CLIENT_ID")
  description = "The Azure Active Directory service principal client ID"
}

variable "client_secret" {
  type        = string
  default     = env("ARM_CLIENT_SECRET")
  description = "The Azure Active Directory service principal client secret"
}

variable "principal_name" {
  type        = string
  default     = env("ARM_PRINCIPAL_NAME")
  description = "Principal name."
}

variable "subscription_id" {
  type        = string
  default     = env("ARM_SUBSCRIPTION_ID")
  description = "The ID of the Azure subscription"
}

variable "tenant_id" {
  type        = string
  default     = env("ARM_TENANT_ID")
  description = "The ID of the Azure Active Directory tenant"
}

variable "resource_group_name" {
  type        = string
  default     = env("ARM_RESOURCE_GROUP_NAME")
  description = "The resource build and managed image resource group name"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "azure-arm" "cowrie" {
  image_offer                       = "0001-com-ubuntu-server-jammy"
  image_publisher                   = "canonical"
  image_sku                         = "22_04-lts-gen2"
  managed_image_name                = "cowrie-server"
  os_type                           = "Linux"
  vm_size                           = "Standard_D2s_v3"
  ssh_clear_authorized_keys         = "true"
  ssh_keep_alive_interval           = "15s"
  ssh_pty                           = "true"
  ssh_timeout                       = "10m"
  ssh_username                      = "ubuntu"
  client_id                         = var.client_id
  client_secret                     = var.client_secret
  subscription_id                   = var.subscription_id
  tenant_id                         = var.tenant_id
  build_resource_group_name         = var.resource_group_name
  managed_image_resource_group_name = var.resource_group_name
}

build {
  sources = ["source.azure-arm.cowrie"]

  provisioner "file" {
    destination = "/tmp/"
    sources = [
      "../defaults",
      "../local.yml",
      "../requirements.yml",
      "../tasks",
      "../templates"
    ]
  }

  provisioner "shell" {
    script = "../scripts/configure.sh"
  }
}
