variable "zone" {
  description = "Zona CloudStack onde o cluster será criado"
  type        = string
}

variable "cluster_name" {
  description = "Prefixo de nome para todos os recursos do cluster"
  type        = string
  default     = "kubespray"
}

# ─── Networking ───────────────────────────────────────────────────────────────
variable "network_id" {
  description = "ID da rede (Tier da VPC) onde as VMs serão conectadas"
  type        = string
}

variable "ip_address_id" {
  description = "ID do IP público (Source NAT) para LB e port forwards"
  type        = string
}

# ─── Nós do Cluster ───────────────────────────────────────────────────────────
variable "nodes" {
  description = <<-EOT
    Grupos de nós do cluster. Cada grupo gera 'count' VMs.
    ssh_base_port é a porta da primeira VM do grupo; as seguintes incrementam +1.
    Exemplo:
      nodes = {
        "control" = { role = "control", count = 1, ssh_base_port = 23000, root_disk_size = 20 }
        "worker"  = { role = "worker",  count = 2, ssh_base_port = 23001, root_disk_size = 20 }
      }
    → gera: control-0 (porta 23000), worker-0 (23001), worker-1 (23002)
  EOT
  type = map(object({
    role           = string  # "control" ou "worker"
    count          = number  # quantidade de VMs neste grupo
    ssh_base_port  = number  # porta do primeiro nó; os seguintes recebem +1, +2, ...
    root_disk_size = number
  }))
}

variable "service_offering" {
  description = "Nome da oferta de serviço do CloudStack para os nós (deve existir previamente)"
  type        = string
}

variable "template" {
  description = "Template de VM do CloudStack (ex: 'Ubuntu 24.04')"
  type        = string
}

variable "keypair_name" {
  description = "Nome do keypair SSH registrado no CloudStack"
  type        = string
}

# ─── Acesso ───────────────────────────────────────────────────────────────────
variable "k8s_api_port" {
  description = "Porta da API do Kubernetes (load balancer)"
  type        = number
  default     = 6443
}
