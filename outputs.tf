output "firewall_id" {
  description = "Firewall generated id"
  value       = azurerm_firewall.firewall[0].id
}

output "firewall_name" {
  value       = azurerm_firewall.firewall[0].name
  description = "Firewall name"
}

output "private_ip_address" {
  value       = azurerm_firewall.firewall[0].ip_configuration[0].private_ip_address
  description = "Firewall private IP"
}

output "public_ip_id" {
  value       = azurerm_public_ip.public_ip[0].id
}

output "public_ip_address" {
  value       = azurerm_public_ip.public_ip[0].ip_address
}

output "firewall_policy_id" {
  value       = azurerm_firewall_policy.policy[0].id
}

output "prefix_public_ip_id" {
  value       = azurerm_public_ip.prefix_public_ip[0].id
}

output "prefix_public_ip_address" {
  value       = azurerm_public_ip.prefix_public_ip[0].ip_address
}

output "public_ip_prefix_id" {
  value       = azurerm_public_ip_prefix.pip-prefix[0].id
}
