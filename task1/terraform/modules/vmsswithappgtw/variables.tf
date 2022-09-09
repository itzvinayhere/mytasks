variable "rg_name" {
  type        = string
  description = "RG name"
}

variable "rg_location" {
  type        = string
  description = "RG name"
}

variable "vmss_name" {
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

variable "subnet_id" {
  type        = string
  description = "subnet name"
}

variable "vnet_name" {
  type        = string
  description = "VNet name"
}

variable "app_gateway_bind_be_pool" {
  type        = string
  description = "app gateway bind to vmss"
}