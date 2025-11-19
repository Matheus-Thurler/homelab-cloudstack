resource "cloudstack_vpc" "vpc_homelab" {
  depends_on   = [cloudstack_network_offering.vpc_k8s_offering]
  name         = var.vpc_name
  display_text = var.vpc_name
  cidr         = var.vpc_cidr
  vpc_offering = var.vpc_offering_name
  zone         = var.zone
}