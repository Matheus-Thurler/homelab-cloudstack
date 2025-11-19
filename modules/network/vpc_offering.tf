resource "cloudstack_network_offering" "vpc_k8s_offering" {
  name          = "VPC Homelab K8s Network Offering"
  display_text  = "VPC Homelab K8s Network Offering"
  guest_ip_type = "Isolated"
  traffic_type  = "Guest"
  for_vpc       = true
  enable        = true
  conserve_mode = true
  supported_services = [
    "SourceNat", "StaticNat", "NetworkACL", "PortForwarding",
    "Lb", "Vpn", "Dhcp", "Dns", "UserData"
  ]
  service_provider_list = {
    "SourceNat"  = "VpcVirtualRouter", "StaticNat" = "VpcVirtualRouter",
    "NetworkACL" = "VpcVirtualRouter", "PortForwarding" = "VpcVirtualRouter",
    "Lb"         = "VpcVirtualRouter", "Vpn" = "VpcVirtualRouter",
    "Dhcp"       = "VpcVirtualRouter", "Dns" = "VpcVirtualRouter",
    "UserData"   = "VpcVirtualRouter"
  }
}