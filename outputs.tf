output "public_ip" {
  description = "IP público do cluster (VPC)"
  value       = module.vpc_network.public_ip
}

output "kubernetes_api" {
  description = "Endpoint da API do Kubernetes"
  value       = "https://${module.vpc_network.public_ip}:6443"
}

output "control_ssh_ports" {
  description = "Mapa de nó control plane → porta SSH"
  value       = module.kubespray.control_ssh_ports
}

output "worker_ssh_ports" {
  description = "Mapa de nó worker → porta SSH"
  value       = module.kubespray.worker_ssh_ports
}

output "control_private_ips" {
  description = "IPs internos dos nós de control plane"
  value       = module.kubespray.control_private_ips
}

output "worker_private_ips" {
  description = "IPs internos dos nós worker"
  value       = module.kubespray.worker_private_ips
}
