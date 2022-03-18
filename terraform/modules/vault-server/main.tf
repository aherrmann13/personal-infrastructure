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

variable "consul_server_ip" {
    type        = string
    description = "consul server ip"
}

variable "image_id" {
    type        = string
    description = "image id from packer snapshot"
}

resource "digitalocean_droplet" "vault-server" {
    count       = "${var.server_count}"
    name        = "vault-server-${count.index + 1}"
    image       = "${var.image_id}"
    region      = "nyc1"
    size        = "s-1vcpu-1gb"
    ssh_keys    = var.ssh_fingerprints

    connection {
      type         = "ssh"
      user         = "root"
      host         = "${self.ipv4_address}"
      agent        = true
      private_key  = file("~/.ssh/id_rsa")
    }


    provisioner "remote-exec" {
      inline = [
        "consul join ${var.consul_server_ip}"
      ]
    }

    provisioner "remote-exec" {
      inline = [
        "chmod +x /scripts/unseal-vault.sh && /scripts/unseal-vault.sh ${count.index}",
        "export VAULT_ADDR='http://${self.ipv4_address_private}:8200'",
        "vault operator raft join http://${digitalocean_droplet.vault-server.0.ipv4_address_private}:8200",
      ]
    }
}