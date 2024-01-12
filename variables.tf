#Module      : LABEL
#Description : Terraform label module variables.
variable "name" {
  type        = string
  default     = null
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "environment" {
  type        = string
  default     = null
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "repository" {
  type        = string
  default     = null
  description = "Terraform current module repo"
}

variable "label_order" {
  type        = list(any)
  default     = ["name", "environment"]
  description = "Label order, e.g. sequence of application name and environment `name`,`environment`,'attribute' [`webserver`,`qa`,`devops`,`public`,] ."
}

variable "managedby" {
  type        = string
  default     = null
  description = "ManagedBy, eg ''."
}

variable "enabled" {
  type        = bool
  default     = true
  description = "Set to false to prevent the module from creating any resources."
}

variable "resource_group_name" {
  type        = string
  default     = null
  description = "A container that holds related resources for an Azure solution"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of tags to add to all resources"
}

#Public IP

variable "public_ip_allocation_method" {
  type        = string
  default     = "Static"
  description = "Defines the allocation method for this IP address. Possible values are Static or Dynamic"
}

variable "public_ip_sku" {
  type        = string
  default     = "Standard"
  description = "The SKU of the Public IP. Accepted values are Basic and Standard. Defaults to Basic"
}

#firewall

variable "threat_intel_mode" {
  type        = string
  default     = "Alert"
  description = "(Optional) The operation mode for threat intelligence-based filtering. Possible values are: Off, Alert, Deny. Defaults to Alert."

  validation {
    condition     = contains(["Off", "Alert", "Deny"], var.threat_intel_mode)
    error_message = "The threat intel mode is invalid."
  }
}

variable "sku_tier" {
  type        = string
  default     = "Standard"
  description = "Specifies the firewall sku tier"
}

variable "sku_policy" {
  default     = "Standard"
  type        = string
  description = "Specifies the firewall-policy sku"
}

variable "base_policy" {
  type        = string
  default     = null
  description = "Specifies the firewall-base-policy-id"
}


variable "dns" {
  type = list(object({
    proxy_enabled = optional(bool, false)
    servers       = set(string)
  }))
  default     = null
  description = "The DNS block within the firewall policy"
}

variable "enable_insights" {
  type        = bool
  default     = false
  description = "Whether to enable insights functionality in the Firewall Policy"
}

variable "insights_enabled" {
  type        = bool
  default     = false
  description = "Whether the insights functionality is enabled for this Firewall Policy"
}

variable "default_log_analytics_workspace_id" {
  type        = string
  default     = null
  description = "The ID of the default Log Analytics Workspace for Firewall Policy logs"
}

variable "insights_retention_in_days" {
  type        = number
  default     = 30
  description = "The log retention period in days for Firewall Policy insights"
}

variable "log_analytics_workspace_location" {
  type        = string
  default     = null
  description = "The location of the Log Analytics Workspace for Firewall Policy insights"
}

variable "threat_ia" {
  type        = string
  default     = null
  description = "The location of the Log Analytics Workspace for Firewall Policy insights"
}

variable "sku_name" {
  type        = string
  default     = "AZFW_VNet"
  description = "(optional) describe your variable"
}

variable "subnet_id" {
  type        = string
  default     = ""
  description = "Subnet ID"
}

variable "nat_policy_collection_group" {
  type        = string
  default     = "DefaultDnatRuleCollectionGroup"
  description = "(optional) Name of nat policy group"
}

variable "net_policy_collection_group" {
  type        = string
  description = "(optional) Name of network policy group"
  default     = "DefaultNetworkRuleCollectionGroup"
}

variable "app_policy_collection_group" {
  type        = string
  default     = "DefaultApplicationRuleCollectionGroup"
  description = "(optional) Name of app policy group"
}

variable "additional_public_ips" {
  type = list(object({
    name                 = string,
    public_ip_address_id = string
  }))
  default     = []
  description = "List of additional public ips' ids to attach to the firewall."
}

variable "application_rule_collection" {
  default     = {}
  description = "One or more application_rule_collection blocks as defined below.."
}

variable "network_rule_collection" {
  default     = {}
  description = "One or more network_rule_collection blocks as defined below."
}

variable "nat_rule_collection" {
  default     = {}
  description = "One or more nat_rule_collection blocks as defined below."
}

variable "public_ip_names" {
  type        = list(string)
  default     = []
  description = ""
}

variable "enable_ip_subnet" {
  type        = bool
  default     = true
  description = "Should subnet id be attached to first public ip name specified in public ip names variable. To be true when there is no individual public ip."
}

variable "location" {
  type        = string
  default     = null
  description = "The location/region where the virtual network is created. Changing this forces a new resource to be created."
}

variable "zone" {
  type        = string
  default     = null
  description = "The Zone for the resources (e.g., `1`, `2`, `3`)."
}

variable "firewall_private_ip_ranges" {
  description = "A list of SNAT private CIDR IP ranges, or the special string `IANAPrivateRanges`, which indicates Azure Firewall does not SNAT when the destination IP address is a private range per IANA RFC 1918."
  type        = list(string)
  default     = null
}

variable "dns_servers" {
  description = "DNS Servers to use with Azure Firewall. Using this also activate DNS Proxy."
  type        = list(string)
  default     = null
}

variable "dns_proxy_enabled" {
  type        = bool
  default     = false
  description = "Flag to enable DNS Proxy on the firewall."
}

variable "virtual_hub" {
  type = object({
    virtual_hub_id  = string
    public_ip_count = number
  })
  default     = null
  description = "An Azure Virtual WAN Hub with associated security and routing policies configured by Azure Firewall Manager. Use secured virtual hubs to easily create hub-and-spoke and transitive architectures with native security services for traffic governance and protection."
}

variable "enable_forced_tunneling" {
  type        = bool
  default     = false
  description = "Route all Internet-bound traffic to a designated next hop instead of going directly to the Internet"
}

variable "firewall_config" {
  type        = string
  default     = null
  description = "Manages an Azure Firewall configuration"
}

variable "dnat-destination_ip" {
  type        = bool
  default     = true
  description = "Variable to specify that you have destination ip to attach to policy or not.(Destination ip is public ip that is attached to firewall)"
}

variable "firewall_loc" {
  type        = string
  default     = null
  description = "log analytics workspace id to pass it to destination details of diagnosys setting of NSG."
}

variable "log_analytics_id" {
  type        = string
  default     = null
  description = "log analytics workspace id to pass it to destination details of diagnosys setting of NSG."
}

# Diagnosis Settings Enable

variable "enable_diagnostic" {
  type        = bool
  default     = false
  description = "Set to false to prevent the module from creating the diagnosys setting for the NSG Resource.."
}

variable "metric_enabled" {
  type        = bool
  default     = true
  description = "Is this Diagnostic Metric enabled? Defaults to True."
}

variable "log_enabled" {
  type        = string
  default     = true
  description = " Is this Diagnostic Log enabled? Defaults to true."
}

variable "storage_account_id" {
  type        = string
  default     = null
  description = "Storage account id to pass it to destination details of diagnosys setting of NSG."
}

variable "eventhub_name" {
  type        = string
  default     = null
  description = "Eventhub Name to pass it to destination details of diagnosys setting of NSG."
}

variable "eventhub_authorization_rule_id" {
  type        = string
  default     = null
  description = "Eventhub authorization rule id to pass it to destination details of diagnosys setting of NSG."
}

variable "log_analytics_workspace_id" {
  type        = string
  default     = null
  description = "log analytics workspace id to pass it to destination details of diagnosys setting of NSG."
}

variable "retention_policy_enabled" {
  type        = bool
  default     = false
  description = "Set to false to prevent the module from creating retension policy for the diagnosys setting."
}

variable "days" {
  type        = number
  default     = 365
  description = "Number of days to create retension policies for te diagnosys setting."
}

variable "firewall_enable" {
  type    = bool
  default = false
}

variable "identity_type" {
  description = "Specifies the type of Managed Service Identity that should be configured on this Storage Account. Possible values are `SystemAssigned`, `UserAssigned`, `SystemAssigned, UserAssigned` (to enable both)."
  type        = string
  default     = "UserAssigned"
}

variable "policy_rule_enabled" {
  type        = bool
  default     = false
  description = "Flag used to control creation of policy rules."
}

variable "firewall_policy_id" {
  type        = string
  default     = null
  description = "The ID of the Firewall Policy."
}

variable "public_ip_prefix_enable" {
  type        = bool
  default     = false
  description = "Flag to control creation of public ip prefix resource."
}

variable "public_ip_prefix_sku" {
  type        = string
  default     = "Standard"
  description = "SKU for public ip prefix. Default to standard."
}

variable "public_ip_prefix_ip_version" {
  type        = string
  default     = "IPv4"
  description = "The IP Version to use, IPv6 or IPv4. Changing this forces a new resource to be created. Default is IPv4"
}

variable "prefix_public_ip_names" {
  type        = list(string)
  default     = []
  description = "Name of prefix public ips."
}

variable "prefix_public_ip_allocation_method" {
  type    = string
  default = "Static"
}

variable "prefix_public_ip_sku" {
  type    = string
  default = "Standard"
}

variable "public_ip_prefix_length" {
  type        = number
  default     = 31
  description = "Specifies the number of bits of the prefix. The value can be set between 0 (4,294,967,296 addresses) and 31 (2 addresses). Defaults to 28(16 addresses). Changing this forces a new resource to be created."
}

variable "enable_prefix_subnet" {
  type        = bool
  default     = false
  description = "Should subnet id be attached to first public ip name specified in public ip prefix name varible. To be true when there is no individual public ip."
}

variable "tls_certificate" {
  type = list(object({
    key_vault_secret_id = string
    name                = string
  }))
  default     = null
  description = "The tls_certificate block within the firewall policy"
}

variable "explict_proxy" {
  type = list(object({
    enabled          = optional(bool, true)
    http_port        = optional(number)
    https_port       = optional(number)
    enable_pac_file  = optional(bool)
    pac_file_port    = optional(number)
    pac_file_sas_url = optional(string)
  }))
  default     = null
  description = "The explict proxy block within the firewall policy"
}

variable "intrusion_detection" {
  type = list(object({
    mode           = optional(string, "Alert")
    private_ranges = optional(set(string))
    signature_overrides = optional(list(object({
      id    = optional(string)
      state = optional(string)
    })))
    traffic_bypass = optional(list(object({
      name                  = optional(string)
      protocol              = optional(string)
      description           = optional(string)
      destination_addresses = optional(list(string))
      destination_ip_groups = optional(list(string))
      destination_ports     = optional(list(string))
      source_addresses      = optional(list(string))
      source_ip_groups      = optional(list(string))
    })))
  }))
  default     = null
  description = "The instruction detection block"
}