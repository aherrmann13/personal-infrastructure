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

resource "digitalocean_droplet" "vault-server" {
    count       = "${var.server_count}"
    name        = "vault-server-${count.index + 1}"
    image       = "ubuntu-20-04-x64"
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
        "mkdir -p /etc/consul.d/client",
        "mkdir -p /etc/vault.d/",
        "mkdir -p /vault/data",
      ]
    }

    provisioner "file" {
      source      = "files/utility/other-software.sh"
      destination = "/tmp/other-software.sh"
    }

    provisioner "file" {
      source      = "files/consul/install.sh"
      destination = "/tmp/install_consul.sh"
    }

    provisioner "file" {
      source      = "files/consul/client/config.hcl"
      destination = "/etc/consul.d/client/config.hcl"
    }

    provisioner "file" {
      source      = "files/consul/consul-client.service"
      destination = "/etc/systemd/system/consul-client.service"
    }

    provisioner "file" {
      source      = "files/vault/install.sh"
      destination = "/tmp/install_vault.sh"
    }

    provisioner "file" {
      source      = "files/vault/config.hcl"
      destination = "/etc/vault.d/config.hcl"
    }

    provisioner "file" {
      source      = "files/vault/vault-server.service"
      destination = "/etc/systemd/system/vault-server.service"
    }

    provisioner "file" {
      source      = "files/vault/unseal-vault.sh"
      destination = "/tmp/unseal_vault.sh"
    }

    provisioner "remote-exec" {
      inline = [
        "chmod +x /tmp/other-software.sh && /tmp/other-software.sh",
        "chmod +x /tmp/install_consul.sh && /tmp/install_consul.sh",
        "chmod +x /tmp/install_vault.sh && /tmp/install_vault.sh ${count.index + 1}",
        "chmod +x /tmp/unseal_vault.sh && /tmp/unseal_vault.sh ${count.index}"
      ]
    }
    
    # Join Consul Cluster
    provisioner "remote-exec" {
      inline = [
        "consul join ${var.consul_server_ip}",
      ]
    }

    # Join Vault Cluster
    provisioner "remote-exec" {
      inline = [
        "export VAULT_ADDR='http://${self.ipv4_address_private}:8200'",
        "vault operator raft join http://${digitalocean_droplet.vault-server.0.ipv4_address_private}:8200",
      ]
    }
}