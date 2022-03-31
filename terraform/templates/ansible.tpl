[consul_servers]
%{ for ip in consul_servers ~}
${ip}
%{ endfor ~}

[vault_servers]
%{ for ip in vault_servers ~}
${ip}
%{ endfor ~}