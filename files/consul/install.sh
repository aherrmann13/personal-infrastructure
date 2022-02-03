#! /bin/bash

## Consul install script

sleep 1m

## https://learn.hashicorp.com/tutorials/consul/get-started-install
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install consul

if [ "$1" == "server" ]; then
	systemctl enable consul-server.service
	systemctl start consul-server.service
else
	systemctl enable consul-client.service
	systemctl start consul-client.service
  	sleep 5
fi
echo "Installation of Consul complete\n"
exit 0