resource "cloudstack_network_acl" "acl_homelab" {
  name   = "acl-k8s-allow-all"
  vpc_id = cloudstack_vpc.vpc_homelab.id
}

resource "cloudstack_network_acl_rule" "allow_ingress" {
  acl_id = cloudstack_network_acl.acl_homelab.id
  rule {
    action       = "allow"
    cidr_list    = ["0.0.0.0/0"]
    protocol     = "all"
    traffic_type = "ingress"

  }
}

resource "cloudstack_network_acl_rule" "allow_egress" {
  acl_id = cloudstack_network_acl.acl_homelab.id
  rule {
    action       = "allow"
    cidr_list    = ["0.0.0.0/0"]
    protocol     = "all"
    traffic_type = "egress"

  }
}
