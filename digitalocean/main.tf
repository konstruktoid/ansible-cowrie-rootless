terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.47.0"
    }
  }
}

variable "region" {
  type        = string
  default     = "fra1"
  description = "DigitalOcean region."
}

variable "do_token" {
  type        = string
  description = "DigitalOcean token."
}

provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_droplet_snapshot" "cowrie_snapshot" {
  name_regex  = "^cowrie-snapshot"
  region      = var.region
  most_recent = true
}

resource "digitalocean_droplet" "cowrie" {
  image      = data.digitalocean_droplet_snapshot.cowrie_snapshot.id
  name       = "cowrie-honeypot"
  region     = var.region
  size       = "s-2vcpu-2gb"
  monitoring = "true"
  tags       = ["honeypot"]
}

resource "digitalocean_firewall" "cowrie_firewall" {
  name        = "cowrie-honeypot-firewall"
  droplet_ids = [digitalocean_droplet.cowrie.id]

  inbound_rule {
    port_range = "22"
    protocol   = "tcp"
    source_addresses = [
      "0.0.0.0/0",
      "::/0",
    ]
    source_droplet_ids        = []
    source_load_balancer_uids = []
    source_tags               = []
  }

  outbound_rule {
    destination_addresses = [
      "0.0.0.0/0",
      "::/0",
    ]
    destination_droplet_ids        = []
    destination_load_balancer_uids = []
    destination_tags               = []
    protocol                       = "icmp"
  }
  outbound_rule {
    destination_addresses = [
      "0.0.0.0/0",
      "::/0",
    ]
    destination_droplet_ids        = []
    destination_load_balancer_uids = []
    destination_tags               = []
    port_range                     = "all"
    protocol                       = "tcp"
  }
  outbound_rule {
    destination_addresses = [
      "0.0.0.0/0",
      "::/0",
    ]
    destination_droplet_ids        = []
    destination_load_balancer_uids = []
    destination_tags               = []
    port_range                     = "all"
    protocol                       = "udp"
  }
}
