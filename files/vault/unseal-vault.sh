#! /bin/bash

## unseal in vault HA needs to be done once per cluster
if [ $1 == "0" ]; then
	sleep 5s
	# init vault, unseal vault and export root token
	VAULT_PROTOCOL="http"
	VAULT_IP=`ifconfig eth1 | grep 'inet ' | cut -d' ' -f10`
	VAULT_PORT="8200"
	export VAULT_ADDR="$VAULT_PROTOCOL://$VAULT_IP:$VAULT_PORT"
	
	vault operator init > /root/startupOutput.txt

	vault operator unseal `grep "Unseal Key 1" /root/startupOutput.txt | cut -d' ' -f4`
	vault operator unseal `grep "Unseal Key 2" /root/startupOutput.txt | cut -d' ' -f4`
	vault operator unseal `grep "Unseal Key 3" /root/startupOutput.txt | cut -d' ' -f4`
fi

exit 0
