resource "cloudstack_kubernetes_cluster" "meu_cluster_k8s" {
  depends_on = [ cloudstack_service_offering.k8s_instance ]
  name               = var.k8s_cluster_name
  zone               = var.zone
  kubernetes_version = var.k8s_semantic_version
  service_offering   = var.k8s_service_offering
  network_id         = var.network_id
  control_nodes_size = var.k8s_control_nodes_size
  size               = var.k8s_worker_nodes_size
  
}