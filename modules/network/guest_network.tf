resource "cloudstack_network" "homelab_network" {
  name             = var.network_name
  cidr             = var.network_cidr
  network_offering = var.network_offering_name
  zone             = cloudstack_vpc.vpc_homelab.zone
  vpc_id           = cloudstack_vpc.vpc_homelab.id

  acl_id = cloudstack_network_acl.acl_homelab.id

  depends_on = [
    cloudstack_network_acl_rule.allow_ingress,
    cloudstack_network_acl_rule.allow_egress
  ]
}
