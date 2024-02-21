output "firewall_id" {
  description = "Firewall generated id"
  value       = try(azurerm_firewall.firewall[*].id, null)
}

output "firewall_name" {
  value       = try(azurerm_firewall.firewall[*].name, null)
  description = "Firewall name"

}

output "private_ip_address" {
  value       = try(azurerm_firewall.firewall[*].ip_configuration[0].private_ip_address, null)
  description = "Firewall private IP"

}

output "public_ip_id" {
  value = try(azurerm_public_ip.public_ip[*].id, null)
}

output "public_ip_address" {
  value = try(azurerm_public_ip.public_ip[*].ip_address, null)
}

output "firewall_policy_id" {
  value = try(azurerm_firewall_policy.policy[*].id, null)
}

output "prefix_public_ip_id" {
  value = try(azurerm_public_ip.prefix_public_ip[*].id, null)
}

output "prefix_public_ip_address" {
  value = try(azurerm_public_ip.prefix_public_ip[*].ip_address, null)
}

output "public_ip_prefix_id" {
  value = try(azurerm_public_ip_prefix.pip-prefix[*].id, null)
}