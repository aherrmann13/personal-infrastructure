terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
  }
}

variable "ssh_fingerprints" {
    type        = list(string)
    description = "SSH fingerprints to enable"
}

variable "server_count" {
    type        = number
    description = "Number of servers to create"
    validation {
      condition     = var.server_count > 2
      error_message = "At least 3 nodes are needed for HA."
    }
}

variable "image_id" {
    type        = string
    description = "image id from packer snapshot"
}

resource "digitalocean_droplet" "consul-server" {
    count       = "${var.server_count}"
    name        = "consul-server-${count.index + 1}"
    image       = "${var.image_id}"
    region      = "nyc1"
    size        = "s-1vcpu-1gb"
    ssh_keys    = var.ssh_fingerprints
}

output "consul_server_private_ips" {
  value       = [for server in digitalocean_droplet.consul-server : server.ipv4_address_private]
  description = "list of the consul server private ip addresses"
}

output "consul_server_public_ips" {
  value       = [for server in digitalocean_droplet.consul-server : server.ipv4_address]
  description = "list of the consul server public ip addresses"
}