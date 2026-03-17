variable "zone" {
  type = string
}

variable "network_id" {
  type = string
}

variable "vms" {
  description = "Mapa de grupos de VMs extras com count"
  type = map(object({
    template         = string
    service_offering = string
    count            = number
    root_disk_size   = number
    keypair_name     = string
  }))
}
