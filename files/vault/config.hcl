service_registration "consul" {
    address = "127.0.0.1:8500"
}

storage "raft" {
  path    = "/vault/data/"
}

listener "tcp" {
  address = "{{ GetInterfaceIP \"eth1\" }}:8200"
  cluster_address = "{{ GetInterfaceIP \"eth1\" }}:8201"
  tls_cert_file = "/certs/tls.crt"
  tls_key_file  = "/certs/tls.key"
}

disable_mlock = true
api_addr = "http://{{ GetInterfaceIP \"eth1\" }}:8200"
cluster_addr = "http://{{ GetInterfaceIP \"eth1\" }}:8201"