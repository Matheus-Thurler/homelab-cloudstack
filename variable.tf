variable "api_key" {
  description = "CloudStack API Key"
  type        = string
  sensitive   = true
}
variable "secret_key" {
  description = "CloudStack Secret Key"
  type        = string
  sensitive   = true
}
variable "api_url" {
  description = "CloudStack API URL"
  type        = string
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



variable "network_name" {
  description = "Name of the guest network"
  type        = string
}

variable "network_cidr" {
  description = "CIDR block for the guest network"
  type        = string
}

variable "vpc_name" {
  description = "Name for the VPC"
  type        = string
}

variable "k8s_semantic_version" {
  description = "The semantic version of the Kubernetes cluster to be deployed."
  type        = string
}
variable "k8s_version_name" {
  description = "The name of the Kubernetes version in CloudStack."
  type        = string
}
variable "k8s_version_url" {
  description = "The URL of the Kubernetes version template."
  type        = string
}
variable "k8s_min_cpu" {
  description = "The minimum number of CPUs required for the Kubernetes version."
  type        = number
}
variable "k8s_min_memory" {
  description = "The minimum memory required for the Kubernetes version."
  type        = number
}

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
  description = "Name of the network offering for the guest network."
  type        = string
}