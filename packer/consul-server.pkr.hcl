packer {
  required_plugins {
    digitalocean = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/digitalocean"
    }
  }
}

variable "do_token" {}


source "digitalocean" "consul-server" {
  api_token     = "${var.do_token}"
  image         = "ubuntu-20-04-x64"
  region        = "nyc1"
  size          = "s-1vcpu-1gb"
  ssh_username  = "root"
  snapshot_name = "consul-server-{{timestamp}}"
}


build {
  sources = ["source.digitalocean.consul-server"]

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

  provisioner "shell" {
    inline = [
      "chmod +x /scripts/install-consul.sh && /scripts/install-consul.sh",
      "chmod +x /scripts/install-other-software.sh && /scripts/install-other-software.sh",
      "mkdir -p /etc/consul.d/server"
    ]
  }

  provisioner "file" {
    source = "../files/consul/server-config.hcl"
    destination = "/etc/consul.d/server/config.hcl"
  }

  provisioner "file" {
    source = "../files/consul/encrypt.hcl"
    destination = "/etc/consul.d/server/encrypt-config.hcl"
  }

  provisioner "file" {
    source      = "../files/consul/consul-server.service"
    destination = "/etc/systemd/system/consul-server.service"
  }

  provisioner "shell" {
    inline = [
      "systemctl enable consul-server.service"
    ]
  }
}