packer {
  required_plugins {
    digitalocean = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/digitalocean"
    }
  }
}

variable "do_token" {}


source "digitalocean" "vault-server" {
  api_token    = "${var.do_token}"
  image        = "ubuntu-20-04-x64"
  region       = "nyc1"
  size         = "s-1vcpu-1gb"
  ssh_username = "root"
  snapshot_name = "vault-server-{{timestamp}}"
}


build {
  sources = ["source.digitalocean.vault-server"]

  provisioner "shell" {
    inline = [
      "mkdir -p /scripts/"
    ]
  }

  provisioner "file" {
    source = "../files/utility/install-other-software.sh"
    destination = "/scripts/install-other-software.sh"
  }

  provisioner "file" {
    source = "../files/consul/install-consul.sh"
    destination = "/scripts/install-consul.sh"
  }

  provisioner "file" {
    source = "../files/vault/install-vault.sh"
    destination = "/scripts/install-vault.sh"
  }

  provisioner "file" {
    source = "../files/vault/unseal-vault.sh"
    destination = "/scripts/unseal-vault.sh"
  }

  provisioner "shell" {
    inline = [
      "chmod +x /scripts/install-consul.sh && /scripts/install-consul.sh",
      "chmod +x /scripts/install-vault.sh && /scripts/install-vault.sh",
      "chmod +x /scripts/install-other-software.sh && /scripts/install-other-software.sh",
      "mkdir -p /etc/consul.d/client",
      "mkdir -p /etc/vault.d/",
      "mkdir -p /vault/data",
    ]
  }

  provisioner "file" {
    source = "../files/consul/client-config.hcl"
    destination = "/etc/consul.d/client/config.hcl"
  }

  provisioner "file" {
    source = "../files/consul/encrypt.hcl"
    destination = "/etc/consul.d/client/config.hcl"
  }

  provisioner "file" {
    source = "../files/vault/config.hcl"
    destination = "/etc/vault.d/config.hcl"
  }

  provisioner "file" {
    source      = "../files/consul/consul-client.service"
    destination = "/etc/systemd/system/consul-client.service"
  }

    provisioner "file" {
    source      = "../files/vault/vault-server.service"
    destination = "/etc/systemd/system/vault-server.service"
  }

  provisioner "shell" {
    inline = [
      "systemctl enable consul-client.service",
      "systemctl enable vault-server.service"
    ]
  }
}