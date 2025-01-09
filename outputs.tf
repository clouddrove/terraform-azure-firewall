output "firewall_id" {
  description = "Firewall generated id"
  value       = join(",", azurerm_firewall.firewall[*].id)
}

output "firewall_name" {
  description = "Firewall name"
  value       = join(",", azurerm_firewall.firewall[*].name)
}

output "private_ip_address" {
  description = "Firewall private IP"
  value       = [for ip in azurerm_firewall.firewall[*].ip_configuration : ip.private_ip_address]
}

output "public_ip_id" {
  description = "Public IP IDs"
  value       = azurerm_public_ip.public_ip[*].id
}

output "public_ip_address" {
  description = "Public IP Addresses"
  value       = azurerm_public_ip.public_ip[*].ip_address
}

output "firewall_policy_id" {
  description = "Firewall Policy ID"
  value       = join(",", azurerm_firewall_policy.policy[*].id)
}

output "prefix_public_ip_id" {
  description = "Prefix Public IP IDs"
  value       = azurerm_public_ip.prefix_public_ip[*].id
}

output "prefix_public_ip_address" {
  description = "Prefix Public IP Addresses"
  value       = azurerm_public_ip.prefix_public_ip[*].ip_address
}

output "public_ip_prefix_id" {
  description = "Public IP Prefix IDs"
  value       = join(",", azurerm_public_ip_prefix.pip-prefix[*].id)
}
