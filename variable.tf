variable "api_key" {
  
}
variable "secret_key" {
  
}
variable "api_url" {
  
}


variable "zone" {
  description = "Zone name for CloudStack resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_offering" {
  description = "Name of the VPC offering"
  type        = string
}

# variable "vpc_offering_name" {
#   description = "VPC offering to use for the VPC"
#   type        = string
# }

variable "network_name" {
  description = "Name of the guest network"
  type        = string
}

variable "network_cidr" {
  description = "CIDR block for the guest network"
  type        = string
}

variable "vpc_name" {

}

variable "k8s_semantic_version" {

}
variable "k8s_version_name" {}
variable "k8s_version_url" {}
variable "k8s_min_cpu" {}
variable "k8s_min_memory" {}

variable "k8s_cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
}

variable "k8s_service_offering" {
  description = "Service offering for Kubernetes nodes"
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
variable "network_offering_name" {
  
}