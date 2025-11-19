variable "k8s_cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
}

variable "zone" {
  description = "Zone name for CloudStack resources"
  type        = string
}

variable "k8s_semantic_version" {
  description = "Semantic version of Kubernetes"
  type        = string
}

variable "k8s_service_offering" {
  description = "Service offering for Kubernetes nodes"
  type        = string
}

variable "network_id" {
  description = "ID of the network where the Kubernetes cluster will be deployed"
  type        = string
}

variable "k8s_control_nodes_size" {
  description = "Number of control plane nodes in the Kubernetes cluster"
  type        = number
}

variable "k8s_worker_nodes_size" {
  description = "Number of worker nodes in the Kubernetes cluster"
  type        = number
}
