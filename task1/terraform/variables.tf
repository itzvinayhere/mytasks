variable "tags" {
  description = "Map of the tags to use for the resources that are deployed"
  type        = map(string)
  default = {
    "environment" = "demo"
    "costcenter"  = "IT"
  }
}

variable "rg_name" {
  type        = string
  description = "RG name"
}

variable "rg_location" {
  type        = string
  description = "RG location"
}

variable "vnet_name" {
  type        = string
  description = "VNet name"
}

variable "vnet_cidr" {
  type        = list(string)
  description = "VNet cidr"
}

variable "nsg_web_name" {
  type        = string
  description = "nsg web name"
}

variable "subnet_gtw_name" {
  type        = string
  description = "web subnet name"
}

variable "subnet_gtw_cidr" {
  type        = list(string)
  description = "web subnet cidr"
}

variable "subnet_web_name" {
  type        = string
  description = "web subnet name"
}

variable "subnet_web_cidr" {
  type        = list(string)
  description = "web subnet cidr"
}

variable "nsg_svc_name" {
  type        = string
  description = "nsg svc name"
}

variable "subnet_svc_name" {
  type        = string
  description = "svc subnet name"
}

variable "subnet_svc_cidr" {
  type        = list(string)
  description = "svc subnet cidr"
}

variable "subnet_pep_name" {
  type        = string
  description = "pep subnet name"
}

variable "subnet_pep_cidr" {
  type        = list(string)
  description = "pep subnet cidr"
}

variable "vmss_web_name" {
  type        = string
  description = "vmss name"
}

variable "vmss_svc_name" {
  type        = string
  description = "vmss name"
}

variable "vmss_sku" {
  type        = string
  description = "vmss sku"
}

variable "vmss_instance_count" {
  type        = number
  description = "vmss instance count"
}

variable "vmss_login_username" {
  type        = string
  description = "vmss login user"
}

variable "app_gateway_name" {
  type        = string
  description = "app gateway name"
}

variable "pip_name" {
  type        = string
  description = "pip name"
}

variable "sql_server_user" {
  type        = string
  description = "sql server user"
}

variable "sql_server_password" {
  type        = string
  sensitive   = true
  description = "sql server password"
}

variable "sql_server_name" {
  type        = string
  description = "sql server name"
}

variable "sql_db_name" {
  type        = string
  description = "sql db name"
}

variable "dns_zone_name" {
  type        = string
  description = "dns zone name"
}

variable "dns_zone_link_name" {
  type        = string
  description = "dns zone link name"
}