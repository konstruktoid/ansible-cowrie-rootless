variable "do_token" {
  type        = string
  default     = ""
  description = "DigitalOcean token."
}

variable "region" {
  type        = string
  default     = "fra1"
  description = "DigitalOcean region."
}

variable "system_user" {
  type        = string
  default     = "kondig"
  description = "Console login username."
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

packer {
  required_plugins {
    digitalocean = {
      version = ">= 1.0.4"
      source  = "github.com/digitalocean/digitalocean"
    }
  }
}

source "digitalocean" "cowrie" {
  droplet_name              = "cowrie-packer-${local.timestamp}"
  image                     = "ubuntu-20-04-x64"
  region                    = var.region
  size                      = "s-2vcpu-2gb"
  snapshot_name             = "cowrie-snapshot"
  ssh_clear_authorized_keys = "true"
  ssh_keep_alive_interval   = "15s"
  ssh_pty                   = "true"
  ssh_timeout               = "10m"
  ssh_username              = "root"
}

build {
  sources = ["source.digitalocean.cowrie"]

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
    environment_vars = [
      "SYSTEM_USER=${var.system_user}"
    ]
    scripts = [
      "../scripts/digitalocean.sh",
      "../scripts/configure.sh"
    ]
  }
}
