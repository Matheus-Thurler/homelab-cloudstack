# ─── VPC Network ─────────────────────────────────────────────────────────────
module "vpc_network" {
  source    = "./modules/vpc-network"
  zone      = var.zone
  vpc_name  = var.vpc_name
  vpc_cidr  = var.vpc_cidr
  tier_name = var.tier_name
  tier_cidr = var.tier_cidr
}

# ─── Kubespray Cluster ────────────────────────────────────────────────────────
module "kubespray" {
  source = "./modules/kubespray-cluster"

  zone         = var.zone
  cluster_name = var.cluster_name

  # Networking (from VPC module)
  network_id    = module.vpc_network.network_id
  ip_address_id = module.vpc_network.public_ip_id

  # Nós do cluster (mapa com role, porta SSH e disco)
  nodes            = var.nodes
  service_offering = var.service_offering
  template         = var.template
  keypair_name     = var.keypair_name

  depends_on = [module.vpc_network]
}

# ─── VMs Extras (opcional) ────────────────────────────────────────────────────
module "extra_vms" {
  count      = var.enable_extra_vms ? 1 : 0
  source     = "./modules/vm"
  zone       = var.zone
  network_id = module.vpc_network.network_id
  vms        = var.extra_vms
}
