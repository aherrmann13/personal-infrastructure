# personal infrastructure

repo for infrastructure for all side projects (ideally)

## consul

### current state

consul is set to bootstrap with three nodes - node 2 and 3 will join node 1 and then the cluster will bootstrap

this setting will stay the same reguardless of how many nodes we need - 3 will elect a leader and the rest can join

### encryption

server to server gossip encryption is done via the encrypt key, server to agent is done via tcp (and therefore can be 
done w/ consul connect)

im stll a little unclear how the vault startup will work - becuase the backend is internal it doesn't need consul to
get up and running but we want to register it in consul so im not sure how the flow looks for initialization + setting
as pki + registering as consul client (so other services can use it) looks like


[source](https://www.consul.io/docs/security/encryption)

## vault

### current state

vault is set up the same way as consul

### seal/unseal
the server starts in a sealed state and needs the unseal keys to start working

the master key is generated and dissasembled into a number of key shares - a subset of which can reassemble the master
key.  my first interation of this i will write the keys to a plaintext file on a single node.  I will join the other
nodes to this node and then unseal those manually.  the plaintext file will need to be backed up somewhere and removed
from the main node

[source](https://www.vaultproject.io/docs/concepts/seal)

## next steps
- use ansible for all provisioners
- vault refresh tls certs after bootstrap
- vault as pki
- vault refresh certs
- nomad
- private ip addressess
- consul encrypt key deployed through consul template
- how to use the hashicorp acl system for permissions
- `prevent_destroy` needs to be enabled on the nodes
- correct user accounts and access on nodes and not just 'root'
- what does a zero downtime image upgrade look like (and how to deploy without my laptop)
- how to secure access to the consul and vault UIs while making them accessable by me
- `digitalocean.consul-server: debconf: unable to initialize frontend: Dialog`
- state should be stored in DO spaces
- pin specific versions of vault/consul/nomad in packer
- how to give things hostnames
- harden vault for production



https://gist.github.com/fntlnz/cf14feb5a46b2eda428e000157447309

https://gist.github.com/Soarez/9688998

add ca here https://support.kerioconnect.gfi.com/hc/en-us/articles/360015200119-Adding-Trusted-Root-Certificates-to-the-Server

https://cyberark-customers.force.com/s/article/How-to-update-the-Vault-server-certificate-when-the-current-certificate-is-about-to-expire