server           = true
datacenter       = "dc1"
data_dir         = "/var/consul"
log_level        = "INFO"
enable_syslog    = true
bind_addr        = "{{ GetInterfaceIP \"eth1\" }}"
bootstrap_expect = 3
ui_config        {
    enabled = true
}
connect          {
    enabled = true
}