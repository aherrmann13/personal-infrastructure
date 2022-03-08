terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
  }
}

provider "digitalocean" {
  token = "${var.do_token}"
}

module "consul-server" {
  source = "./modules/consul-server"
  ssh_fingerprints = ["${var.lt_ssh_fingerprint}", "${var.tab_ssh_fingerprint}"]
  server_count = 3
}

module "vault-server" {
  source = "./modules/vault-server"
  ssh_fingerprints = ["${var.lt_ssh_fingerprint}", "${var.tab_ssh_fingerprint}"]
  server_count = 3
  consul_server_ip = module.consul-server.consul_server_ips.0
}