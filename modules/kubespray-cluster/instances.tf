# ─── Expansão dos grupos em nós individuais ───────────────────────────────────
# Converte o mapa de grupos (com count) em um mapa flat de nós individuais.
# Chave estável: "group-index" (ex: "worker-0", "worker-1")
# → adicionar count não destrói nós existentes; só cria os novos.
locals {
  expanded_nodes = merge([
    for group_name, group in var.nodes : {
      for i in range(group.count) :
      "${group_name}-${i}" => {
        role           = group.role
        ssh_port       = group.ssh_base_port + i
        root_disk_size = group.root_disk_size
      }
    }
  ]...)
}

# ─── Instâncias ───────────────────────────────────────────────────────────────
resource "cloudstack_instance" "node" {
  for_each = local.expanded_nodes

  name             = "${var.cluster_name}-${each.key}"
  display_name     = "${var.cluster_name}-${each.key}"
  zone             = var.zone
  template         = var.template
  service_offering = var.service_offering
  network_id       = var.network_id
  keypair          = var.keypair_name
  root_disk_size   = each.value.root_disk_size
  expunge          = true
}
