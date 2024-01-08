provider "azurerm" {
  features {}
}

locals {
  name        = "app"
  environment = "test"
}

##----------------------------------------------------------------------------- 
## Resource Group module call
## Resource group in which all resources will be deployed.
##-----------------------------------------------------------------------------
module "resource_group" {
  source      = "clouddrove/resource-group/azure"
  version     = "1.0.2"
  name        = local.name
  environment = local.environment
  label_order = ["name", "environment", ]
  location    = "East US"
}

##----------------------------------------------------------------------------- 
## Virtual Network module call.
## Virtual Network in firewall specific subnet will be created. 
##-----------------------------------------------------------------------------
module "vnet" {
  depends_on          = [module.resource_group]
  source              = "clouddrove/vnet/azure"
  version             = "1.0.3"
  name                = local.name
  environment         = local.environment
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_space       = "10.0.0.0/16"
}

##----------------------------------------------------------------------------- 
## Subnet module call. 
## Name specific subnet for firewall will be created. 
##-----------------------------------------------------------------------------
module "name_specific_subnet" {
  depends_on           = [module.vnet]
  source               = "clouddrove/subnet/azure"
  version              = "1.1.0"
  name                 = local.name
  environment          = local.environment
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = join("", module.vnet.vnet_name)
  #subnet
  specific_name_subnet  = true
  specific_subnet_names = "AzureFirewallSubnet"
  subnet_prefixes       = ["10.0.1.0/24"]
  # route_table
  routes = [
    {
      name           = "rt-test"
      address_prefix = "0.0.0.0/0"
      next_hop_type  = "Internet"
    }
  ]
}

##----------------------------------------------------------------------------- 
## Log Analytic Module Call.
## Log Analytic workspace for firerwall diagnostic setting. 
##-----------------------------------------------------------------------------
module "log-analytics" {
  source                           = "clouddrove/log-analytics/azure"
  version                          = "1.0.1"
  name                             = local.name
  environment                      = local.environment
  label_order                      = ["name", "environment"]
  create_log_analytics_workspace   = true
  log_analytics_workspace_sku      = "PerGB2018"
  resource_group_name              = module.resource_group.resource_group_name
  log_analytics_workspace_location = module.resource_group.resource_group_location
}

##----------------------------------------------------------------------------- 
## Firewall module call. 
## All firewall related resources will be deployed from this module, i.e. including firewall and firewall rules.
##-----------------------------------------------------------------------------
module "firewall" {
  depends_on              = [module.name_specific_subnet]
  source                  = "../.."
  name                    = local.name
  environment             = local.environment
  resource_group_name     = module.resource_group.resource_group_name
  location                = module.resource_group.resource_group_location
  subnet_id               = module.name_specific_subnet.specific_subnet_id[0]
  public_ip_prefix_enable = true
  prefix_public_ip_names  = ["test-1", "test-2"]
  public_ip_prefix_length = 31
  enable_prefix_subnet    = true

  # additional_public_ips = [{
  # name = "public-ip_name",
  # public_ip_address_id = "public-ip_resource_id"
  #   } ]
  firewall_enable            = true
  policy_rule_enabled        = true
  enable_diagnostic          = false
  log_analytics_workspace_id = module.log-analytics.workspace_id

  application_rule_collection = [
    {
      name     = "example_app_policy"
      priority = 200
      action   = "Allow"
      rules = [
        {
          name              = "app_test"
          source_addresses  = ["*"] // ["X.X.X.X"]
          destination_fqdns = ["*"] // ["X.X.X.X"]
          protocols = [
            {
              port = "443"
              type = "Https"
            },
            {
              port = "80"
              type = "Http"
            }
          ]
        }
      ]
    }
  ]

  network_rule_collection = [
    {
      name     = "example_network_policy"
      priority = "100"
      action   = "Allow"
      rules = [
        {
          name                  = "ssh"
          protocols             = ["TCP"]
          source_addresses      = ["*"] // ["X.X.X.X"]
          destination_addresses = ["*"] // ["X.X.X.X"]
          destination_ports     = ["22"]
        }

      ]
    },
    {
      name     = "example_network_policy-2"
      priority = "101"
      action   = "Allow"
      rules = [
        {
          name                  = "smtp"
          protocols             = ["TCP"]
          source_addresses      = ["*"] // ["X.X.X.X"]
          destination_addresses = ["*"] // ["X.X.X.X"]
          destination_ports     = ["587"]
        }
      ]
    }
  ]

  nat_rule_collection = [
    {
      name     = "example_nat_policy-1"
      priority = "101"
      rules = [
        {
          name                = "http"
          protocols           = ["TCP"]
          source_addresses    = ["*"] // ["X.X.X.X"]
          destination_ports   = ["80"]
          source_addresses    = ["*"]
          translated_port     = "80"
          translated_address  = "10.1.1.1"                                  #provide private ip address to translate
          destination_address = module.firewall.prefix_public_ip_address[1] //Public ip associated with firewall. Here index 1 indicates 'vnet ip' (from public_ip_names     = ["ingress" , "vnet"])

        },
        {
          name                = "https"
          protocols           = ["TCP"]
          destination_ports   = ["443"]
          source_addresses    = ["*"]
          translated_port     = "443"
          translated_address  = "10.1.1.1"                                  #provide private ip address to translate
          destination_address = module.firewall.prefix_public_ip_address[1] //Public ip associated with firewall

        }
      ]
    },

    {
      name     = "example-nat-policy-2"
      priority = "100"
      rules = [
        {
          name                = "http"
          protocols           = ["TCP"]
          source_addresses    = ["*"] // ["X.X.X.X"]
          destination_ports   = ["80"]
          translated_port     = "80"
          translated_address  = "10.1.1.2"                                  #provide private ip address to translate
          destination_address = module.firewall.prefix_public_ip_address[0] //Public ip associated with firewall.Here index 0 indicates 'ingress ip' (from public_ip_names     = ["ingress" , "vnet"])

        },
        {
          name                = "https"
          protocols           = ["TCP"]
          source_addresses    = ["*"] // ["X.X.X.X"]
          destination_ports   = ["443"]
          translated_port     = "443"
          translated_address  = "10.1.1.2"                                  #provide private ip address to translate
          destination_address = module.firewall.prefix_public_ip_address[0] //Public ip associated with firewall
        }
      ]
    }
  ]
}
