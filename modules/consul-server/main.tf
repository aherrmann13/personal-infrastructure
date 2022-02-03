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

resource "digitalocean_droplet" "consul-server" {
    count       = "${var.server_count}"
    name        = "consul-server-${count.index + 1}"
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
        "mkdir -p /etc/consul.d/server"
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
      source      = "files/consul/server/config.hcl"
      destination = "/etc/consul.d/server/config.hcl"
    }

    provisioner "file" {
      source      = "files/consul/consul-server.service"
      destination = "/etc/systemd/system/consul-server.service"
    }

    provisioner "remote-exec" {
      inline = [
        "chmod +x /tmp/other-software.sh",
        "/tmp/other-software.sh server",
        "chmod +x /tmp/install_consul.sh",
        "/tmp/install_consul.sh server",
      ]
    }

    # Join Consul Servers
    provisioner "remote-exec" {
      inline = [
        "consul join ${digitalocean_droplet.consul-server.0.ipv4_address_private}",
      ]
    }
}