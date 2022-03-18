# personal infrastructure

repo for infrastructure for all side projects (ideally)

## consul

### current state

consul is set to bootstrap with three nodes - node 2 and 3 will join node 1 and then the cluster will bootstrap

this setting will stay the same reguardless of how many nodes we need - 3 will elect a leader and the rest can join

### future improvements

1. need to remove public ip address and use private only
   * will we need a bastion host?
   * we may need a packer image.  this has the advantage of allowing me to manually add nodes without additional config
   * cloud init may also solve the need to configure from ssh
1. need to learn the consul acl system to bootstrap tokens and provide some sort of security
1. need to set up consul-template
   * need to have an encypt key for consul from vault
1. `prevent_destroy` needs to be enabled on the nodes
1. correct user accounts and access on nodes and not just 'root'


## vault

### current state

vault is set up the same way as consul

### seal/unseal
the server starts in a sealed state and needs the unseal keys to start working

the master key is generated and dissasembled into a number of key shares - a subset of which can reassemble the master
key.  my first interation of this i will write the keys to a plaintext file on each node.  after they are on the node
i can pull them off manually and store them safely.

[source](https://www.vaultproject.io/docs/concepts/seal)

ramblings to format correctly

> When running in HA mode, this happens once per cluster, not per server. During initialization, the encryption keys are generated, unseal keys are created, and the initial root token is created.

https://github.com/hashicorp/vault/issues/10630

https://www.reddit.com/r/devops/comments/d6vedw/problem_with_hashicorp_vault_high_availability/

### future improvements
1. figure out HA backend
1. get it working
1. tls on each host
1. the initial vault install unseals the leader node and leaves the unsealing of the remaining nodes up to someone to do manually (or copy files)
  * the tl;dr is no matter what the setup is someone needs to copy a root key from one server to another if its totally automated
  * this is fine for now






## general fixes

fix all file names so they dont get renamed on the server