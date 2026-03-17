variable "zone" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "vpc_offering" {
  type    = string
  default = "Default VPC offering"
}

variable "tier_name" {
  type = string
}

variable "tier_cidr" {
  type = string
}

variable "network_offering" {
  type    = string
  default = "DefaultIsolatedNetworkOfferingForVpcNetworks"
}
