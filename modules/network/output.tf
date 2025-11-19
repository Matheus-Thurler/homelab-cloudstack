output "network_id" {
  value = cloudstack_network.homelab_network.id
}

output "vpc_id" {
  value = cloudstack_vpc.vpc_homelab.id
}