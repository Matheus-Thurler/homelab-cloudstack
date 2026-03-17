# ─── VPC ──────────────────────────────────────────────────────────────────────
resource "cloudstack_vpc" "this" {
  name         = var.vpc_name
  display_text = var.vpc_name
  cidr         = var.vpc_cidr
  vpc_offering = var.vpc_offering
  zone         = var.zone
}

# ─── VPC ACLs ─────────────────────────────────────────────────────────────────
resource "cloudstack_network_acl" "kubernetes" {
  name   = "k8s-acl"
  vpc_id = cloudstack_vpc.this.id
}

# ─── Network Tier ─────────────────────────────────────────────────────────────
resource "cloudstack_network" "tier" {
  name             = var.tier_name
  display_text     = var.tier_name
  cidr             = var.tier_cidr
  network_offering = var.network_offering
  zone             = var.zone
  vpc_id           = cloudstack_vpc.this.id
  acl_id           = cloudstack_network_acl.kubernetes.id
}

# ─── IP Address (Public) ──────────────────────────────────────────────────────
resource "cloudstack_ipaddress" "public_ip" {
  vpc_id = cloudstack_vpc.this.id
  zone   = var.zone
}

# ─── VPC ACL Rules ────────────────────────────────────────────────────────────
resource "cloudstack_network_acl_rule" "ssh_internal" {
  acl_id = cloudstack_network_acl.kubernetes.id

  rule {
    action    = "allow"
    cidr_list = ["0.0.0.0/0"]
    protocol  = "tcp"
    port      = "22"
    traffic_type = "ingress"
  }
}

resource "cloudstack_network_acl_rule" "ssh_public" {
  acl_id = cloudstack_network_acl.kubernetes.id

  rule {
    action    = "allow"
    cidr_list = ["0.0.0.0/0"]
    protocol  = "tcp"
    port      = "22000-23999"
    traffic_type = "ingress"
  }
}

resource "cloudstack_network_acl_rule" "k8s_api" {
  acl_id = cloudstack_network_acl.kubernetes.id

  rule {
    action    = "allow"
    cidr_list = ["0.0.0.0/0"]
    protocol  = "tcp"
    port      = "6443"
    traffic_type = "ingress"
  }
}
