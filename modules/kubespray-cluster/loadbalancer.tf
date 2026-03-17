# ─── Load Balancer Rule → Kubernetes API (6443) ───────────────────────────────
locals {
  control_instance_ids = [
    for k, v in local.expanded_nodes : cloudstack_instance.node[k].id
    if v.role == "control"
  ]
}

resource "cloudstack_loadbalancer_rule" "k8s_api" {
  name          = "${var.cluster_name}-api"
  description   = "Kubernetes API Server"
  ip_address_id = var.ip_address_id
  network_id    = var.network_id
  algorithm     = "roundrobin"
  private_port  = var.k8s_api_port
  public_port   = var.k8s_api_port
  protocol      = "tcp"

  member_ids = local.control_instance_ids

  depends_on = [cloudstack_instance.node]
}
