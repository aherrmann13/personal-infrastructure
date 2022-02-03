# personal infrastructure

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
