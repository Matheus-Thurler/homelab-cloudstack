# ─── Kubespray Inventory (gerado localmente) ──────────────────────────────────
data "cloudstack_ipaddress" "public" {
  filter {
    name  = "id"
    value = var.ip_address_id
  }
}

locals {
  control_nodes = { for k, v in local.expanded_nodes : k => v if v.role == "control" }
  worker_nodes  = { for k, v in local.expanded_nodes : k => v if v.role == "worker" }

  control_entries = [
    for k, v in local.control_nodes :
    "${var.cluster_name}-${k} ansible_host=${data.cloudstack_ipaddress.public.ip_address} ansible_port=${v.ssh_port} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa ip=${cloudstack_instance.node[k].ip_address} access_ip=${cloudstack_instance.node[k].ip_address} ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'"
  ]

  worker_entries = [
    for k, v in local.worker_nodes :
    "${var.cluster_name}-${k} ansible_host=${data.cloudstack_ipaddress.public.ip_address} ansible_port=${v.ssh_port} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa ip=${cloudstack_instance.node[k].ip_address} access_ip=${cloudstack_instance.node[k].ip_address} ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'"
  ]

  inventory_content = <<-INI
[all]
${join("\n", local.control_entries)}
${join("\n", local.worker_entries)}

[kube_control_plane]
${join("\n", [for k in keys(local.control_nodes) : "${var.cluster_name}-${k}"])}

[etcd]
${join("\n", [for k in keys(local.control_nodes) : "${var.cluster_name}-${k}"])}

[kube_node]
${join("\n", [for k in keys(local.worker_nodes) : "${var.cluster_name}-${k}"])}

[k8s_cluster:children]
kube_control_plane
kube_node

[all:vars]
loadbalancer_apiserver_ip=${data.cloudstack_ipaddress.public.ip_address}
loadbalancer_apiserver_port=${var.k8s_api_port}
apiserver_loadbalancer_domain_name=${data.cloudstack_ipaddress.public.ip_address}
supplementary_addresses_in_ssl_keys='["${data.cloudstack_ipaddress.public.ip_address}"]'
INI
}

resource "local_file" "kubespray_inventory" {
  content  = local.inventory_content
  filename = "${path.root}/ansible-inventory/hosts.ini"

  depends_on = [cloudstack_instance.node]
}
