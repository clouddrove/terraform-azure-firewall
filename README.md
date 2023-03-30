<!-- This file was automatically generated by the `geine`. Make all changes to `README.yaml` and run `make readme` to rebuild this file. -->

<p align="center"> <img src="https://user-images.githubusercontent.com/50652676/62349836-882fef80-b51e-11e9-99e3-7b974309c7e3.png" width="100" height="100"></p>


<h1 align="center">
    Terraform AZURE FIREWALL
</h1>

<p align="center" style="font-size: 1.2rem;"> 
    Terraform module to create firewall resource on AZURE.
     </p>

<p align="center">

<a href="https://www.terraform.io">
  <img src="https://img.shields.io/badge/Terraform-v1.0.0-green" alt="Terraform">
</a>
<a href="LICENSE.md">
  <img src="https://img.shields.io/badge/License-APACHE-blue.svg" alt="Licence">
</a>


</p>
<p align="center">

<a href='https://facebook.com/sharer/sharer.php?u=https://github.com/clouddrove/terraform-azure-firewall'>
  <img title="Share on Facebook" src="https://user-images.githubusercontent.com/50652676/62817743-4f64cb80-bb59-11e9-90c7-b057252ded50.png" />
</a>
<a href='https://www.linkedin.com/shareArticle?mini=true&title=Terraform+AZURE+FIREWALL&url=https://github.com/clouddrove/terraform-azure-firewall'>
  <img title="Share on LinkedIn" src="https://user-images.githubusercontent.com/50652676/62817742-4e339e80-bb59-11e9-87b9-a1f68cae1049.png" />
</a>
<a href='https://twitter.com/intent/tweet/?text=Terraform+AZURE+FIREWALL&url=https://github.com/clouddrove/terraform-azure-firewall'>
  <img title="Share on Twitter" src="https://user-images.githubusercontent.com/50652676/62817740-4c69db00-bb59-11e9-8a79-3580fbbf6d5c.png" />
</a>

</p>
<hr>


We eat, drink, sleep and most importantly love **DevOps**. We are working towards strategies for standardizing architecture while ensuring security for the infrastructure. We are strong believer of the philosophy <b>Bigger problems are always solved by breaking them into smaller manageable problems</b>. Resonating with microservices architecture, it is considered best-practice to run database, cluster, storage in smaller <b>connected yet manageable pieces</b> within the infrastructure. 

This module is basically combination of [Terraform open source](https://www.terraform.io/) and includes automatation tests and examples. It also helps to create and improve your infrastructure with minimalistic code instead of maintaining the whole infrastructure code yourself.

We have [*fifty plus terraform modules*][terraform_modules]. A few of them are comepleted and are available for open source usage while a few others are in progress.




## Prerequisites

This module has a few dependencies: 

- [Terraform 1.x.x](https://learn.hashicorp.com/terraform/getting-started/install.html)
- [Go](https://golang.org/doc/install)
- [github.com/stretchr/testify/assert](https://github.com/stretchr/testify)
- [github.com/gruntwork-io/terratest/modules/terraform](https://github.com/gruntwork-io/terratest)







## Examples


**IMPORTANT:** Since the `master` branch used in `source` varies based on new modifications, we suggest that you use the release versions [here](https://github.com/clouddrove/terraform-azure-firewall/releases).


### Simple Example
Here is an example of how you can use this module in your inventory structure:
```hcl
  module "firewall" {
    depends_on           = [module.name_specific_subnet]
    source               = "clouddrove/firewall/azure"
    name                 = "app"
    environment          = "test"
    label_order          = ["name", "environment"]
    resource_group_name  = module.resource_group.resource_group_name
    location             = module.resource_group.resource_group_location
    subnet_id            = module.name_specific_subnet.specific_subnet_id[0]
    public_ip_names      = ["ingress", "vnet"] // Name of public ips you want to create.

  # additional_public_ips = [{
  # name = "public-ip_name",
  # public_ip_address_id = "public-ip_resource_id"
  #   } ]



   dnat-destination_ip = true  // To be true when dnat policy is to be created.

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
        translated_address  = "X.X.X.X"
        destination_address = module.firewall.public_ip_address[1] //Public ip associated with firewall. Here index 1 indicates 'vnet ip' (from public_ip_names     = ["ingress" , "vnet"])

      },
      {
        name                = "https"
        protocols           = ["TCP"]
        destination_ports   = ["443"]
        source_addresses    = ["*"]
        translated_port     = "443"
        translated_address  = "X.X.X.X"
        destination_address = module.firewall.public_ip_address[1] //Public ip associated with firewall

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
        translated_address  = ["X.X.X.X"]
        destination_address = module.firewall.public_ip_address[0] //Public ip associated with firewall.Here index 0 indicates 'ingress ip' (from public_ip_names     = ["ingress" , "vnet"])

      },
      {
        name                = "https"
        protocols           = ["TCP"]
        source_addresses    = ["*"] // ["X.X.X.X"]
        destination_ports   = ["443"]
        translated_port     = "443"
        translated_address  = ["X.X.X.X"]
        destination_address = module.firewall.public_ip_address[0] //Public ip associated with firewall
      }
    ]
  }
 ]
}

  ```






## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| additional\_public\_ips | List of additional public ips' ids to attach to the firewall. | <pre>list(object({<br>    name                 = string,<br>    public_ip_address_id = string<br>  }))</pre> | `[]` | no |
| app\_policy\_collection\_group | (optional) Name of app policy group | `string` | `"DefaultApplicationRuleCollectionGroup"` | no |
| application\_rule\_collection | One or more application\_rule\_collection blocks as defined below.. | `map` | `{}` | no |
| days | Number of days to create retension policies for te diagnosys setting. | `number` | `365` | no |
| dnat-destination\_ip | Variable to specify that you have destination ip to attach to policy or not.(Destination ip is public ip that is attached to firewall) | `bool` | `false` | no |
| dns\_servers | DNS Servers to use with Azure Firewall. Using this also activate DNS Proxy. | `list(string)` | `null` | no |
| enable\_diagnostic | Set to false to prevent the module from creating the diagnosys setting for the NSG Resource.. | `bool` | `false` | no |
| enabled | Set to false to prevent the module from creating any resources. | `bool` | `true` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| eventhub\_authorization\_rule\_id | Eventhub authorization rule id to pass it to destination details of diagnosys setting of NSG. | `string` | `null` | no |
| eventhub\_name | Eventhub Name to pass it to destination details of diagnosys setting of NSG. | `string` | `null` | no |
| firewall\_private\_ip\_ranges | A list of SNAT private CIDR IP ranges, or the special string `IANAPrivateRanges`, which indicates Azure Firewall does not SNAT when the destination IP address is a private range per IANA RFC 1918. | `list(string)` | `null` | no |
| label\_order | Label order, e.g. sequence of application name and environment `name`,`environment`,'attribute' [`webserver`,`qa`,`devops`,`public`,] . | `list(any)` | `[]` | no |
| location | The location/region where the virtual network is created. Changing this forces a new resource to be created. | `string` | `""` | no |
| log\_analytics\_workspace\_id | log analytics workspace id to pass it to destination details of diagnosys setting of NSG. | `string` | `null` | no |
| managedby | ManagedBy, eg ''. | `string` | `""` | no |
| name | Name  (e.g. `app` or `cluster`). | `string` | `""` | no |
| nat\_policy\_collection\_group | (optional) Name of nat policy group | `string` | `"DefaultDnatRuleCollectionGroup"` | no |
| nat\_rule\_collection | One or more nat\_rule\_collection blocks as defined below. | `map` | `{}` | no |
| net\_policy\_collection\_group | (optional) Name of network policy group | `string` | `"DefaultNetworkRuleCollectionGroup"` | no |
| network\_rule\_collection | One or more network\_rule\_collection blocks as defined below. | `map` | `{}` | no |
| public\_ip\_allocation\_method | Defines the allocation method for this IP address. Possible values are Static or Dynamic | `string` | `"Static"` | no |
| public\_ip\_names | n/a | `list(string)` | `[]` | no |
| public\_ip\_sku | The SKU of the Public IP. Accepted values are Basic and Standard. Defaults to Basic | `string` | `"Standard"` | no |
| repository | Terraform current module repo | `string` | `""` | no |
| resource\_group\_name | A container that holds related resources for an Azure solution | `string` | `""` | no |
| retention\_policy\_enabled | Set to false to prevent the module from creating retension policy for the diagnosys setting. | `bool` | `false` | no |
| sku\_name | (optional) describe your variable | `string` | `"AZFW_VNet"` | no |
| sku\_tier | Specifies the firewall sku tier | `string` | `"Standard"` | no |
| storage\_account\_id | Storage account id to pass it to destination details of diagnosys setting of NSG. | `string` | `null` | no |
| subnet\_id | Subnet ID | `string` | `""` | no |
| tags | A map of tags to add to all resources | `map(string)` | `{}` | no |
| threat\_intel\_mode | (Optional) The operation mode for threat intelligence-based filtering. Possible values are: Off, Alert, Deny. Defaults to Alert. | `string` | `"Alert"` | no |

## Outputs

| Name | Description |
|------|-------------|
| firewall\_id | Firewall generated id |
| firewall\_name | Firewall name |
| private\_ip\_address | Firewall private IP |
| public\_ip\_address | n/a |
| public\_ip\_id | n/a |




## Testing
In this module testing is performed with [terratest](https://github.com/gruntwork-io/terratest) and it creates a small piece of infrastructure, matches the output like ARN, ID and Tags name etc and destroy infrastructure in your AWS account. This testing is written in GO, so you need a [GO environment](https://golang.org/doc/install) in your system. 

You need to run the following command in the testing folder:
```hcl
  go test -run Test
```



## Feedback 
If you come accross a bug or have any feedback, please log it in our [issue tracker](https://github.com/clouddrove/terraform-azure-firewall/issues), or feel free to drop us an email at [hello@clouddrove.com](mailto:hello@clouddrove.com).

If you have found it worth your time, go ahead and give us a ★ on [our GitHub](https://github.com/clouddrove/terraform-azure-firewall)!

## About us

At [CloudDrove][website], we offer expert guidance, implementation support and services to help organisations accelerate their journey to the cloud. Our services include docker and container orchestration, cloud migration and adoption, infrastructure automation, application modernisation and remediation, and performance engineering.

<p align="center">We are <b> The Cloud Experts!</b></p>
<hr />
<p align="center">We ❤️  <a href="https://github.com/clouddrove">Open Source</a> and you can check out <a href="https://github.com/clouddrove">our other modules</a> to get help with your new Cloud ideas.</p>

  [website]: https://clouddrove.com
  [github]: https://github.com/clouddrove
  [linkedin]: https://cpco.io/linkedin
  [twitter]: https://twitter.com/clouddrove/
  [email]: https://clouddrove.com/contact-us.html
  [terraform_modules]: https://github.com/clouddrove?utf8=%E2%9C%93&q=terraform-&type=&language=
