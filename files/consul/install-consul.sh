#! /bin/bash

sleep 15s

## https://learn.hashicorp.com/tutorials/consul/get-started-install
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

sleep 15s

sudo apt-get update

sleep 15s

sudo apt-get install consul