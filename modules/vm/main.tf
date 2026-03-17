# Expansão dos grupos de VMs extras
locals {
  expanded_vms = merge([
    for group_name, group in var.vms : {
      for i in range(group.count) :
      "${group_name}-${i}" => {
        template         = group.template
        service_offering = group.service_offering
        root_disk_size   = group.root_disk_size
        keypair_name     = group.keypair_name
      }
    }
  ]...)
}

resource "cloudstack_instance" "this" {
  for_each = local.expanded_vms

  name             = each.key
  display_name     = each.key
  zone             = var.zone
  template         = each.value.template
  service_offering = each.value.service_offering
  network_id       = var.network_id
  keypair          = each.value.keypair_name
  root_disk_size   = each.value.root_disk_size
  expunge          = true
}
