##----------------------------------------------------------------------------- 
## Labels module callled that will be used for naming and tags.   
##-----------------------------------------------------------------------------
module "labels" {
  source      = "clouddrove/labels/azure"
  version     = "1.0.0"
  name        = var.name
  environment = var.environment
  managedby   = var.managedby
  label_order = var.label_order
  repository  = var.repository
}

##----------------------------------------------------------------------------- 
## Below resource will create Public ip in your environment.
## These are individual public ips i.e. does not belong to prefix list. 
## This public ip will be attached to firewall.    
##-----------------------------------------------------------------------------
resource "azurerm_public_ip" "public_ip" {
  count                = var.enabled && var.firewall_enable ? length(var.public_ip_names) : 0
  name                 = format("%s-%s-ip", module.labels.id, var.public_ip_names[count.index])
  location             = var.location
  resource_group_name  = var.resource_group_name
  allocation_method    = var.public_ip_allocation_method
  sku                  = var.public_ip_sku
  ddos_protection_mode = "VirtualNetworkInherited"
  tags                 = module.labels.tags
}



##----------------------------------------------------------------------------- 
## Below resource will create Public ip prefix list in your environment.
## Prefix Public ip will be allocated from this prefix list.    
##-----------------------------------------------------------------------------
resource "azurerm_public_ip_prefix" "pip-prefix" {
  count               = var.enabled && var.firewall_enable && var.public_ip_prefix_enable ? 1 : 0
  name                = format("%s-public-ip-prefix", module.labels.id)
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.public_ip_prefix_sku
  ip_version          = var.public_ip_prefix_ip_version
  prefix_length       = var.public_ip_prefix_length
  tags                = module.labels.tags
}

##----------------------------------------------------------------------------- 
## Below resource will create Public ip in your environment.
## These public ip will be allocated from prefix list created above. 
##-----------------------------------------------------------------------------
resource "azurerm_public_ip" "prefix_public_ip" {
  count                = var.enabled && var.firewall_enable && var.public_ip_prefix_enable ? length(var.prefix_public_ip_names) : 0
  name                 = format("%s-%s-pip", module.labels.id, var.prefix_public_ip_names[count.index])
  location             = var.location
  resource_group_name  = var.resource_group_name
  allocation_method    = var.prefix_public_ip_allocation_method
  sku                  = var.prefix_public_ip_sku
  public_ip_prefix_id  = azurerm_public_ip_prefix.pip-prefix[0].id
  ddos_protection_mode = "VirtualNetworkInherited"
  tags                 = module.labels.tags
}


##----------------------------------------------------------------------------- 
## Below resource will deploy firewall in environment. 
## If you don't have to deploy firewall and only deploy firewall rules than set 'var.firewall_enable' variable to false.   
##-----------------------------------------------------------------------------
resource "azurerm_firewall" "firewall" {
  count               = var.enabled && var.firewall_enable ? 1 : 0
  name                = format("%s-firewall", module.labels.id)
  location            = var.location
  resource_group_name = var.resource_group_name
  threat_intel_mode   = var.threat_intel_mode
  sku_tier            = var.sku_tier
  sku_name            = var.sku_name
  firewall_policy_id  = azurerm_firewall_policy.policy[0].id
  zones               = var.zone != null ? [var.zone] : []
  tags                = module.labels.tags
  private_ip_ranges   = var.firewall_private_ip_ranges
  dns_servers         = var.dns_servers
  dns_proxy_enabled   = var.dns_proxy_enabled

  dynamic "ip_configuration" {
    for_each = var.public_ip_names
    iterator = it
    content {
      name = format("%s-%s-ipconfig", module.labels.id, it.value)
      # var.enable_ip_subnet will be true when individual public ip and prefix public ip both are to be deployed (none of them exist before) or only individual public ip are to be deployed.
      # var.enable_ip_subnet will be false when prefix_public_ip already exists and there are no individual public ip.
      subnet_id            = var.enable_ip_subnet ? it.key == 0 ? var.subnet_id : null : null
      public_ip_address_id = azurerm_public_ip.public_ip[it.key].id
    }
  }

  dynamic "ip_configuration" {
    for_each = var.prefix_public_ip_names
    iterator = it
    content {
      name = format("%s-%s-pipconfig", module.labels.id, it.value)
      # var.enable_prefix_subnet will only be true when prefix public ips are to be deployed during initial apply and there are no individual public ips to be created.
      # Individual public ips can be deployed after initial apply and var.enable_ip_subnet variable must be false. 
      subnet_id            = var.enable_prefix_subnet ? it.key == 0 ? var.subnet_id : null : null
      public_ip_address_id = azurerm_public_ip.prefix_public_ip[it.key].id
    }
  }

  dynamic "ip_configuration" {
    for_each = toset(var.additional_public_ips)

    content {
      name                 = ip_configuration.value.name
      public_ip_address_id = ip_configuration.value.public_ip_address_id
    }
  }

  dynamic "virtual_hub" {
    for_each = var.virtual_hub != null ? [var.virtual_hub] : []
    content {
      virtual_hub_id  = virtual_hub.value.virtual_hub_id
      public_ip_count = virtual_hub.value.public_ip_count
    }
  }

  dynamic "management_ip_configuration" {
    for_each = var.enable_forced_tunneling ? [1] : []
    content {
      name                 = lower("${var.firewall_config.name}-forced-tunnel")
      subnet_id            = azurerm_subnet.fw-mgnt-snet[0].id
      public_ip_address_id = azurerm_public_ip.fw-mgnt-pip[0].id
    }
  }

  lifecycle {
    ignore_changes = [
      tags,

    ]
  }
}

##----------------------------------------------------------------------------- 
## Below resource will create firewall policy in your environment. 
## Firewall policy can only be deployed along firewall. If only firewall rules are to be deployed than firewall policy must be present in azure environment in which rules are to be deployed.   
##-----------------------------------------------------------------------------
resource "azurerm_firewall_policy" "policy" {
  count               = var.enabled && var.firewall_enable ? 1 : 0
  name                = format("%s-firewall-FirewallPolicy", module.labels.id)
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku_policy
  base_policy_id      = var.base_policy

  dynamic "identity" {
    for_each = var.identity_type != null && var.sku_policy == "Premium" && var.sku_tier == "Premium" ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_type == "UserAssigned" ? [azurerm_user_assigned_identity.identity[0].id] : null
    }
  }

  dynamic "dns" {
    for_each = var.dns != null ? var.dns : []
    content {
      proxy_enabled = dns.value.proxy_enabled
      servers       = toset(dns.value.servers)
    }
  }

  dynamic "insights" {
    for_each = var.insights != null ? var.insights : []
    content {
      default_log_analytics_workspace_id = insights.value.default_log_analytics_workspace_id
      enabled                            = insights.value.enabled
      retention_in_days                  = insights.value.retention_in_days

      dynamic "log_analytics_workspace" {
        for_each = insights.value.log_analytics_workspace != null ? [insights.value.log_analytics_workspace] : []
        content {
          id                = log_analytics_workspace.value.id
          firewall_location = var.location
        }
      }
    }
  }

  dynamic "threat_intelligence_allowlist" {
    for_each = var.threat_ia != null ? [var.threat_ia] : []
    content {
      ip_addresses = threat_intelligence_allowlist.value.ip_addresses
      fqdns        = threat_intelligence_allowlist.value.fqdns
    }
  }

  dynamic "tls_certificate" {
    for_each = var.tls_certificate != null ? var.tls_certificate : []
    content {
      key_vault_secret_id = tls_certificate.value.key_vault_secret_id
      name                = tls_certificate.value.name
    }
  }

  dynamic "explicit_proxy" {
    for_each = var.explict_proxy != null ? var.explict_proxy : []
    content {
      enabled         = explicit_proxy.value.enabled
      http_port       = explicit_proxy.value.http_port
      https_port      = explicit_proxy.value.https_port
      enable_pac_file = explicit_proxy.value.enable_pac_file
      pac_file_port   = explicit_proxy.value.pac_file_port
      pac_file        = explicit_proxy.value.pac_file_sas_url
    }
  }

  dynamic "intrusion_detection" {
    for_each = var.intrusion_detection != null ? var.intrusion_detection : []
    content {
      mode           = intrusion_detection.value.mode
      private_ranges = toset(intrusion_detection.value.private_ranges)

      dynamic "signature_overrides" {
        for_each = intrusion_detection.value.signature_overrides != null ? intrusion_detection.value.signature_overrides : []

        content {
          id    = signature_overrides.value.id
          state = signature_overrides.value.state
        }
      }

      dynamic "traffic_bypass" {
        for_each = intrusion_detection.value.traffic_bypass != null ? intrusion_detection.value.traffic_bypass : []
        content {
          name                  = traffic_bypass.value.name
          protocol              = traffic_bypass.value.protocol
          description           = traffic_bypass.value.description
          destination_addresses = traffic_bypass.value.destination_addresses
          destination_ip_groups = traffic_bypass.value.destination_ip_groups
          destination_ports     = traffic_bypass.value.destination_ports
          source_addresses      = traffic_bypass.value.source_addresses
          source_ip_groups      = traffic_bypass.value.source_ip_groups
        }
      }
    }
  }
}

##----------------------------------------------------------------------------- 
## Below resource will deploy a user assigned identity. 
## This identity will be attached to created firewall policy. So, can be created only when firewall policy is created using this module. 
##-----------------------------------------------------------------------------
resource "azurerm_user_assigned_identity" "identity" {
  count               = var.enabled && var.firewall_enable ? 1 : 0
  location            = var.location
  name                = format("%s-fw-policy", module.labels.id)
  resource_group_name = var.resource_group_name
}

##----------------------------------------------------------------------------- 
## Below resource will create firewall policy rule collection group. 
## All application rules will be there in this group. 
##-----------------------------------------------------------------------------
resource "azurerm_firewall_policy_rule_collection_group" "app_policy_rule_collection_group" {
  count              = var.enabled && var.policy_rule_enabled ? 1 : 0
  name               = var.app_policy_collection_group
  firewall_policy_id = var.firewall_policy_id == null ? azurerm_firewall_policy.policy[0].id : var.firewall_policy_id
  priority           = 300

  dynamic "application_rule_collection" {
    for_each = var.application_rule_collection

    content {
      name     = application_rule_collection.value.name
      priority = application_rule_collection.value.priority
      action   = application_rule_collection.value.action

      dynamic "rule" {
        for_each = application_rule_collection.value.rules
        content {
          name              = lookup(rule.value, "name", null)              # string
          source_addresses  = lookup(rule.value, "source_addresses", null)  # list # currently the IP of staging rule, needs to be changed
          source_ip_groups  = lookup(rule.value, "source_ip_groups", null)  # list Specifies a list of source IP groups.
          destination_fqdns = lookup(rule.value, "destination_fqdns", null) # list of destination IP groups.
          dynamic "protocols" {
            for_each = rule.value.protocols
            content {
              port = lookup(protocols.value, "port", null)
              type = lookup(protocols.value, "type", null)
            }
          }
        }
      }
    }
  }
}

##----------------------------------------------------------------------------- 
## Below resource will create firewall policy rule collection group. 
## All network rules will be there in this group. 
##-----------------------------------------------------------------------------
resource "azurerm_firewall_policy_rule_collection_group" "network_policy_rule_collection_group" {
  count              = var.enabled && var.policy_rule_enabled ? 1 : 0
  name               = var.net_policy_collection_group
  firewall_policy_id = var.firewall_policy_id == null ? azurerm_firewall_policy.policy[0].id : var.firewall_policy_id
  priority           = 200


  dynamic "network_rule_collection" {
    for_each = var.network_rule_collection
    content {
      name     = network_rule_collection.value.name
      priority = network_rule_collection.value.priority
      action   = network_rule_collection.value.action

      dynamic "rule" {
        for_each = network_rule_collection.value.rules
        content {
          name                  = rule.value.name                                   # string
          protocols             = rule.value.protocols                              # list
          destination_ports     = rule.value.destination_ports                      # list - Required
          source_addresses      = lookup(rule.value, "source_addresses", null)      # list
          source_ip_groups      = lookup(rule.value, "source_ip_groups", null)      # list Specifies a list of source IP groups.
          destination_addresses = lookup(rule.value, "destination_addresses", null) # list - ["192.168.1.1", "192.168.1.2"]
          destination_ip_groups = lookup(rule.value, "destination_ip_groups", null) # list of destination IP groups.
          destination_fqdns     = lookup(rule.value, "destination_fqdns", null)     # list of destination fqdns groups.
        }
      }
    }
  }
}

##----------------------------------------------------------------------------- 
## Below resource will create firewall policy rule collection group. 
## All dnat rules will be there in this group. 
##-----------------------------------------------------------------------------
resource "azurerm_firewall_policy_rule_collection_group" "nat_policy_rule_collection_group" {
  count              = var.enabled && var.dnat-destination_ip && var.policy_rule_enabled ? 1 : 0
  name               = var.nat_policy_collection_group
  firewall_policy_id = var.firewall_policy_id == null ? azurerm_firewall_policy.policy[0].id : var.firewall_policy_id
  priority           = 100

  dynamic "nat_rule_collection" {
    for_each = var.nat_rule_collection
    content {
      name     = nat_rule_collection.value.name
      priority = nat_rule_collection.value.priority
      action   = "Dnat"

      dynamic "rule" {
        for_each = nat_rule_collection.value.rules
        content {
          name                = rule.value.name                                 # string
          protocols           = rule.value.protocols                            # list
          destination_ports   = rule.value.destination_ports                    # list - Required
          source_addresses    = lookup(rule.value, "source_addresses", null)    # list
          destination_address = lookup(rule.value, "destination_address", null) # string
          translated_address  = lookup(rule.value, "translated_address", null)  # list of translated address.
          translated_port     = lookup(rule.value, "translated_port", null)     # port
        }
      }
    }
  }
}

##----------------------------------------------------------------------------- 
## Below resource will create diagnostic setting for firewall. 
##-----------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "firewall_diagnostic-setting" {
  count                          = var.enabled && var.enable_diagnostic ? 1 : 0
  name                           = format("firewall-diagnostic-log")
  target_resource_id             = azurerm_firewall.firewall[0].id
  storage_account_id             = var.storage_account_id
  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  # log_analytics_destination_type = var.log_analytics_destination_type

  dynamic "enabled_log" {
    for_each = var.log_enabled ? ["allLogs"] : []
    content {
      category_group = enabled_log.value
    }
  }
  dynamic "metric" {
    for_each = var.metric_enabled ? ["AllMetrics"] : []
    content {
      category = metric.value
      enabled  = true
    }
  }
  lifecycle {
    ignore_changes = [enabled_log, metric]
  }
}

resource "azurerm_monitor_diagnostic_setting" "public_ip_diagnostic-setting" {
  count                          = var.enabled && var.enable_diagnostic && length(var.public_ip_names) > 0 ? length(var.public_ip_names) : 0
  name                           = format("public-ip-diagnostic-log")
  target_resource_id             = azurerm_public_ip.public_ip[count.index].id
  storage_account_id             = var.storage_account_id
  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id
  log_analytics_workspace_id     = var.log_analytics_workspace_id

  dynamic "metric" {
    for_each = var.metric_enabled ? ["AllMetrics"] : []
    content {
      category = metric.value
      enabled  = true
    }
  }
  dynamic "enabled_log" {
    for_each = var.pip_logs.enabled ? var.pip_logs.category != null ? var.pip_logs.category : var.pip_logs.category_group : []
    content {
      category       = var.pip_logs.category != null ? enabled_log.value : null
      category_group = var.pip_logs.category == null ? enabled_log.value : null
    }
  }
  lifecycle {
    ignore_changes = [log_analytics_destination_type]
  }
}

resource "azurerm_monitor_diagnostic_setting" "pip_prefix_diagnostic-setting" {
  count                          = var.enabled && var.enable_diagnostic && length(var.prefix_public_ip_names) > 0 ? length(var.prefix_public_ip_names) : 0
  name                           = format("public-ip-diagnostic-log")
  target_resource_id             = azurerm_public_ip.prefix_public_ip[count.index].id
  storage_account_id             = var.storage_account_id
  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id
  log_analytics_workspace_id     = var.log_analytics_workspace_id

  dynamic "metric" {
    for_each = var.metric_enabled ? ["AllMetrics"] : []
    content {
      category = metric.value
      enabled  = true
    }
  }
  dynamic "enabled_log" {
    for_each = var.pip_logs.enabled ? var.pip_logs.category != null ? var.pip_logs.category : var.pip_logs.category_group : []
    content {
      category       = var.pip_logs.category != null ? enabled_log.value : null
      category_group = var.pip_logs.category == null ? enabled_log.value : null
    }
  }
  lifecycle {
    ignore_changes = [log_analytics_destination_type]
  }
}