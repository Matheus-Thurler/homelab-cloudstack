# ─── Provider Auth ────────────────────────────────────────────────────────────
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

# ─── General ──────────────────────────────────────────────────────────────────
variable "zone" {
  description = "CloudStack zone name"
  type        = string
}
# ─── VPC Network ─────────────────────────────────────────────────────────────
variable "vpc_name" {
  description = "Nome da VPC no CloudStack"
  type        = string
  default     = "homelab-vpc"
}

variable "vpc_cidr" {
  description = "CIDR da VPC"
  type        = string
  default     = "10.50.0.0/16"
}

variable "tier_name" {
  description = "Nome do Tier (subnet) da VPC para o Kubernetes"
  type        = string
  default     = "k8s-tier"
}

variable "tier_cidr" {
  description = "CIDR do Tier da VPC"
  type        = string
  default     = "10.50.1.0/24"
}

# ─── Kubespray Cluster ────────────────────────────────────────────────────────
variable "cluster_name" {
  description = "Base name for all cluster VM resources"
  type        = string
  default     = "kubespray"
}

variable "template" {
  description = "Name of the VM template in CloudStack (e.g. 'Ubuntu-22.04-LTS')"
  type        = string
}
# ─── Nós do Cluster Kubernetes ───────────────────────────────────────────────
variable "nodes" {
  description = "Grupos de nós do cluster. Cada grupo expande 'count' VMs com chaves estáveis."
  type = map(object({
    role           = string  # control | worker
    count          = number  # quantidade de VMs neste grupo
    ssh_base_port  = number  # porta do primeiro nó; seguintes recebem +1, +2...
    root_disk_size = number
  }))
  default = {}
}

variable "service_offering" {
  description = "Nome da oferta de serviço CloudStack para os nós do cluster"
  type        = string
}

# ─── Keypair ──────────────────────────────────────────────────────────────────
variable "keypair_name" {
  description = "Name of the SSH keypair registered in CloudStack"
  type        = string
  default     = "teste"
}

# ─── VMs Extras ───────────────────────────────────────────────────────────────
variable "enable_extra_vms" {
  description = "Habilita ou desabilita a criação de VMs extras"
  type        = bool
  default     = false
}

variable "extra_vms" {
  description = "Mapa de VMs extras na mesma VPC. Deixe vazio ({}) para não criar nenhuma."
  type = map(object({
    template         = string
    service_offering = string
    count            = number
    root_disk_size   = number
    keypair_name     = string
  }))
  default = {}
}

