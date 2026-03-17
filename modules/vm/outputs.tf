output "vm_ids" {
  description = "Mapa de nome da VM → ID no CloudStack"
  value       = { for k, v in cloudstack_instance.this : k => v.id }
}

output "vm_ips" {
  description = "Mapa de nome da VM → IP privado"
  value       = { for k, v in cloudstack_instance.this : k => v.ip_address }
}
