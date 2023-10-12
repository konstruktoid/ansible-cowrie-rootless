variable "region" {
  type    = string
  default = "eu-west-3"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.6"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "cowrie" {
  ami_name      = "cowrie-packer-${local.timestamp}"
  instance_type = "t3.small"
  region        = var.region
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/*ubuntu-jammy-22.04-amd64-server*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_clear_authorized_keys = "true"
  ssh_keep_alive_interval   = "15s"
  ssh_pty                   = "true"
  ssh_timeout               = "10m"
  ssh_username              = "ubuntu"
}

build {
  sources = ["source.amazon-ebs.cowrie"]

  provisioner "file" {
    destination = "/tmp/"
    sources = [
      "../defaults",
      "../local.yml",
      "../tasks",
      "../templates"
    ]
  }

  provisioner "shell" {
    script = "../scripts/configure.sh"
  }
}
