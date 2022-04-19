[consul_servers]
%{ for ip in consul_servers ~}
${ip}
%{ endfor ~}

[consul_servers_private]
%{ for ip in consul_servers_private ~}
${ip}
%{ endfor ~}

[vault_servers]
%{ for ip in vault_servers ~}
${ip}
%{ endfor ~}