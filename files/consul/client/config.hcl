server        = false
datacenter    = "dc1"
data_dir      = "/var/consul"
log_level     = "INFO"
enable_syslog = true
bind_addr     = "{{ GetInterfaceIP \"eth1\" }}"