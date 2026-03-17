output "kubernetes_api_endpoint" {
  description = "Endpoint da API do Kubernetes via load balancer"
  value       = "https://${data.cloudstack_ipaddress.public.ip_address}:${var.k8s_api_port}"
}

output "control_ssh_ports" {
  description = "Mapa de nome do nó control → porta SSH pública"
  value = {
    for k, v in local.expanded_nodes : "${var.cluster_name}-${k}" => v.ssh_port
    if v.role == "control"
  }
}

output "worker_ssh_ports" {
  description = "Mapa de nome do nó worker → porta SSH pública"
  value = {
    for k, v in local.expanded_nodes : "${var.cluster_name}-${k}" => v.ssh_port
    if v.role == "worker"
  }
}

output "control_private_ips" {
  description = "IPs privados dos nós de control plane"
  value       = [for k, v in local.expanded_nodes : cloudstack_instance.node[k].ip_address if v.role == "control"]
}

output "worker_private_ips" {
  description = "IPs privados dos nós worker"
  value       = [for k, v in local.expanded_nodes : cloudstack_instance.node[k].ip_address if v.role == "worker"]
}

output "public_ip" {
  description = "IP público usado para LB e port forwards SSH"
  value       = data.cloudstack_ipaddress.public.ip_address
}
