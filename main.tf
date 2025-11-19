module "network" {
  source            = "./modules/network"
  zone              = var.zone
  vpc_cidr          = var.vpc_cidr
  vpc_offering_name = var.vpc_offering
  vpc_name          = var.vpc_name
  network_name      = var.network_name
  network_cidr      = var.network_cidr
  network_offering_name = var.network_offering_name
  # vpc_offering      = var.vpc_offering
}

module "k8s_version" {
  source               = "./modules/kubernetes-version"
  k8s_semantic_version = var.k8s_semantic_version
  k8s_version_name     = var.k8s_version_name
  k8s_version_url      = var.k8s_version_url
  k8s_min_cpu          = var.k8s_min_cpu
  k8s_min_memory       = var.k8s_min_memory
}


module "kubernetes" {
  depends_on = [module.k8s_version, module.network]
  source                 = "./modules/kubernetes-cluster"
  k8s_cluster_name       = var.k8s_cluster_name
  zone                   = var.zone
  k8s_service_offering   = var.k8s_service_offering
  network_id             = module.network.network_id
  k8s_control_nodes_size = var.k8s_control_nodes_size
  k8s_worker_nodes_size  = var.k8s_worker_nodes_size
  k8s_semantic_version   = module.k8s_version.kubernetes_version
}