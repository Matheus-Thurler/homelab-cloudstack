output "vpc_id" {
  value = cloudstack_vpc.this.id
}

output "network_id" {
  value = cloudstack_network.tier.id
}

output "public_ip" {
  value = cloudstack_ipaddress.public_ip.ip_address
}

output "public_ip_id" {
  value = cloudstack_ipaddress.public_ip.id
}
