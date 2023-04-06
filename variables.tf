#Module      : LABEL
#Description : Terraform label module variables.
variable "name" {
  type        = string
  default     = ""
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "repository" {
  type        = string
  default     = ""
  description = "Terraform current module repo"
}

variable "label_order" {
  type        = list(any)
  default     = []
  description = "Label order, e.g. sequence of application name and environment `name`,`environment`,'attribute' [`webserver`,`qa`,`devops`,`public`,] ."
}

variable "managedby" {
  type        = string
  default     = ""
  description = "ManagedBy, eg ''."
}

variable "enabled" {
  type        = bool
  description = "Set to false to prevent the module from creating any resources."
  default     = true
}

variable "resource_group_name" {
  description = "A container that holds related resources for an Azure solution"
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

#Public IP

variable "public_ip_allocation_method" {
  description = "Defines the allocation method for this IP address. Possible values are Static or Dynamic"
  default     = "Static"
}

variable "public_ip_sku" {
  description = "The SKU of the Public IP. Accepted values are Basic and Standard. Defaults to Basic"
  default     = "Standard"
}

#firewall

variable "threat_intel_mode" {
  description = "(Optional) The operation mode for threat intelligence-based filtering. Possible values are: Off, Alert, Deny. Defaults to Alert."
  default     = "Alert"
  type        = string

  validation {
    condition     = contains(["Off", "Alert", "Deny"], var.threat_intel_mode)
    error_message = "The threat intel mode is invalid."
  }
}

variable "sku_tier" {
  description = "Specifies the firewall sku tier"
  default     = "Standard"
  type        = string
}

variable "sku_policy" {
  description = "Specifies the firewall-policy sku"
  default     = "Standard"
  type        = string
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

variable "location" {
  type        = string
  default     = ""
  description = "The location/region where the virtual network is created. Changing this forces a new resource to be created."
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

variable "dnat-destination_ip" {
  description = "Variable to specify that you have destination ip to attach to policy or not.(Destination ip is public ip that is attached to firewall)"
  type        = bool
  default     = false
}

# Diagnosis Settings Enable

variable "enable_diagnostic" {
  type        = bool
  default     = false
  description = "Set to false to prevent the module from creating the diagnosys setting for the NSG Resource.."
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

variable "identity_type" {
  description = "Specifies the type of Managed Service Identity that should be configured on this Storage Account. Possible values are `SystemAssigned`, `UserAssigned`, `SystemAssigned, UserAssigned` (to enable both)."
  type        = string
  default     = "UserAssigned"
}