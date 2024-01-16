output "firewall_id" {
  description = "Firewall generated id"
  value       = var.enabled && var.firewall_enable ? azurerm_firewall.firewall[0].id : null
}

output "firewall_name" {
  value       = var.enabled && var.firewall_enable ? azurerm_firewall.firewall[0].name : null
  description = "Firewall name"

}

output "private_ip_address" {
  value       = azurerm_firewall.firewall[*].ip_configuration[0].private_ip_address
  description = "Firewall private IP"

}

output "public_ip_id" {
  value = azurerm_public_ip.public_ip[*].id
}

output "public_ip_address" {
  value = azurerm_public_ip.public_ip[*].ip_address
}

output "firewall_policy_id" {
  value = var.enabled && var.firewall_enable ? azurerm_firewall_policy.policy[0].id : null
}

output "prefix_public_ip_id" {
  value = azurerm_public_ip.prefix_public_ip[*].id
}

output "prefix_public_ip_address" {
  value = azurerm_public_ip.prefix_public_ip[*].ip_address
}

output "public_ip_prefix_id" {
  value = azurerm_public_ip_prefix.pip-prefix[*].id
}