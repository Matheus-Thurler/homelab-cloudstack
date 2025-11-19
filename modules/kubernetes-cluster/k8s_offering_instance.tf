resource "cloudstack_service_offering" "k8s_instance" {
    name = "K8s Instance"
    cpu_number = 2
    display_text = "K8s Instance"
    memory = 8192
    cpu_speed = 2000
}