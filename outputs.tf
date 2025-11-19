output "kubernetes_cluster_id" {
  description = "The ID of the Kubernetes cluster"
  value       = module.kubernetes.cluster_id
}

output "network_id" {
  description = "The ID of the created network"
  value       = module.network.network_id
}

output "vpc_id" {
  description = "The ID of the created VPC"
  value       = module.network.vpc_id
}
