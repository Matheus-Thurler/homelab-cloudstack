resource "cloudstack_kubernetes_version" "v1_33_1" {
  semantic_version = var.k8s_semantic_version
  name             = var.k8s_version_name
  url              = var.k8s_version_url
  min_cpu          = var.k8s_min_cpu
  min_memory       = var.k8s_min_memory
}