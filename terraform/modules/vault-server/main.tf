terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
    tls = {
      source = "hashicorp/tls"
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

variable "tls_private_key" {
    type        = string
    description = "pem encoded private key for tls certificate."
}

variable "tls_ca_cert" {
    type        = string
    description = "pem encoded root ca cert."
}

variable "tls_ca_private_key" {
    type        = string
    description = "pem encoded root ca private key."
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

}

resource "tls_cert_request" "vault_csr" {
  key_algorithm   = "RSA"
  private_key_pem = var.tls_private_key
  ip_addresses    = [for server in digitalocean_droplet.vault-server : server.ipv4_address_private]

  subject {
    organization = "AdamHerrmann"
    country = "US"
  }
}

resource "tls_locally_signed_cert" "vault_crt" {
  cert_request_pem   = tls_cert_request.vault_csr.cert_request_pem
  ca_key_algorithm   = "RSA"
  ca_private_key_pem = var.tls_ca_private_key
  ca_cert_pem        = var.tls_ca_cert

  validity_period_hours = 48

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}


resource "null_resource" "provision" {
  count       = "${var.server_count}"

  connection {
    type         = "ssh"
    user         = "root"
    host         = digitalocean_droplet.vault-server[count.index].ipv4_address
    agent        = false
    private_key  = file("~/.ssh/id_rsa")
  }

  provisioner "remote-exec" {
    inline = [
      "echo '${tls_locally_signed_cert.vault_crt.cert_pem}' > /certs/tls.crt",
      "echo '${var.tls_private_key}' > /certs/tls.key"
    ]
  }

  provisioner "remote-exec" {
     inline = [
       "consul join ${var.consul_server_ip}"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "echo ${null_resource.provision.0.id}",
      "sleep 10s",
      "chmod +x /scripts/unseal-vault.sh && /scripts/unseal-vault.sh ${count.index}",
      "export VAULT_ADDR='https://${digitalocean_droplet.vault-server[count.index].ipv4_address_private}:8200'",
      "vault operator raft join https://${digitalocean_droplet.vault-server.0.ipv4_address_private}:8200",
    ]
  } 
}