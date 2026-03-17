# ─── SSH Port Forwards ────────────────────────────────────────────────────────
resource "cloudstack_port_forward" "ssh" {
  for_each      = local.expanded_nodes
  ip_address_id = var.ip_address_id

  forward {
    protocol           = "tcp"
    private_port       = 22
    public_port        = each.value.ssh_port
    virtual_machine_id = cloudstack_instance.node[each.key].id
  }

  depends_on = [cloudstack_instance.node]
}
