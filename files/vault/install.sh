#! /bin/bash

## Vault install script

sleep 1m

## https://learn.hashicorp.com/tutorials/vault/get-started-install
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install vault

nodeid="node-$1"
sed -i "s/replaceme-nodeid/$nodeid/g" /etc/vault.d/config.hcl

systemctl enable vault-server.service
systemctl start vault-server.service

echo "Installation of Vault complete\n"
exit 0