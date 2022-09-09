terraform {
  required_providers {
    azurerm = {
      version = "3.21.1"
      source  = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.rg_location
  tags     = var.tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.vnet_cidr
}

resource "azurerm_network_security_group" "webnsg" {
  name                = var.nsg_web_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "http_80"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = var.tags
}

resource "azurerm_subnet" "appgtwsubnet" {
  name                 = var.subnet_gtw_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_gtw_cidr
}

resource "azurerm_subnet" "websubnet" {
  name                 = var.subnet_web_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_web_cidr
}

resource "azurerm_network_security_group" "svcnsg" {
  name                = var.nsg_svc_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "http_8080"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = var.tags
}

resource "azurerm_subnet" "svcsubnet" {
  name                 = var.subnet_svc_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_svc_cidr
}

resource "azurerm_subnet_network_security_group_association" "web" {
  subnet_id                 = azurerm_subnet.websubnet.id
  network_security_group_id = azurerm_network_security_group.webnsg.id
  depends_on = [
    azurerm_network_security_group.webnsg, azurerm_subnet.websubnet
  ]
}

resource "azurerm_subnet_network_security_group_association" "svc" {
  subnet_id                 = azurerm_subnet.svcsubnet.id
  network_security_group_id = azurerm_network_security_group.svcnsg.id
  depends_on = [
    azurerm_network_security_group.svcnsg, azurerm_subnet.svcsubnet
  ]
}

resource "azurerm_subnet" "pepsubnet" {
  name                                          = var.subnet_pep_name
  resource_group_name                           = azurerm_resource_group.rg.name
  virtual_network_name                          = azurerm_virtual_network.vnet.name
  address_prefixes                              = var.subnet_pep_cidr
  private_endpoint_network_policies_enabled     = false
  private_link_service_network_policies_enabled = false
}

module "vmssweb" {
  source                   = "./modules/vmsswithappgtw"
  rg_name                  = azurerm_resource_group.rg.name
  rg_location              = azurerm_resource_group.rg.location
  vmss_name                = var.vmss_web_name
  vmss_sku                 = var.vmss_sku
  vmss_instance_count      = var.vmss_instance_count
  vmss_login_username      = var.vmss_login_username
  subnet_id                = azurerm_subnet.websubnet.id
  vnet_name                = var.vnet_name
  app_gateway_bind_be_pool = "${azurerm_application_gateway.appgtw.id}/backendAddressPools/${var.app_gateway_name}-be-pool"
}

module "vmsssvc" {
  source              = "./modules/vmss"
  rg_name             = azurerm_resource_group.rg.name
  rg_location         = azurerm_resource_group.rg.location
  vmss_name           = var.vmss_svc_name
  vmss_sku            = var.vmss_sku
  vmss_instance_count = var.vmss_instance_count
  vmss_login_username = var.vmss_login_username
  subnet_id           = azurerm_subnet.svcsubnet.id
  vnet_name           = var.vnet_name
}

resource "azurerm_public_ip" "pip" {
  name                = var.pip_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Dynamic"
}

resource "azurerm_application_gateway" "appgtw" {
  name                = var.app_gateway_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "${var.app_gateway_name}-gtw-ip-cfg"
    subnet_id = azurerm_subnet.appgtwsubnet.id
  }

  frontend_port {
    name = "${var.app_gateway_name}-fe-port"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "${var.app_gateway_name}-fe-ip-cfg"
    public_ip_address_id = azurerm_public_ip.pip.id
  }

  backend_address_pool {
    name = "${var.app_gateway_name}-be-pool"
  }

  backend_http_settings {
    name                  = "${var.app_gateway_name}-be-http-stg"
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "${var.app_gateway_name}-listener"
    frontend_ip_configuration_name = "${var.app_gateway_name}-fe-ip-cfg"
    frontend_port_name             = "${var.app_gateway_name}-fe-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "${var.app_gateway_name}-req-route-rule"
    rule_type                  = "Basic"
    http_listener_name         = "${var.app_gateway_name}-listener"
    backend_address_pool_name  = "${var.app_gateway_name}-be-pool"
    backend_http_settings_name = "${var.app_gateway_name}-be-http-stg"
  }
  depends_on = [
    azurerm_public_ip.pip
  ]
}

resource "azurerm_mssql_server" "sqlserver" {
  name                         = var.sql_server_name
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = var.sql_server_user
  administrator_login_password = var.sql_server_password
}

resource "azurerm_mssql_database" "sqldatabase" {
  name                 = var.sql_db_name
  server_id            = azurerm_mssql_server.sqlserver.id
  collation            = "SQL_Latin1_General_CP1_CI_AS"
  license_type         = "LicenseIncluded"
  max_size_gb          = 1
  read_scale           = false
  sku_name             = "S0"
  zone_redundant       = false
  storage_account_type = "Local"

  tags = var.tags
}

resource "azurerm_private_dns_zone" "dnszone" {
  name                = var.dns_zone_name
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dnszonelink" {
  name                  = var.dns_zone_link_name
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dnszone.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

resource "azurerm_private_endpoint" "pe" {
  name                = "${var.sql_server_name}-ep"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.pepsubnet.id

  private_service_connection {
    name                           = "${var.sql_server_name}-ep-svc-conn"
    is_manual_connection           = "false"
    private_connection_resource_id = azurerm_mssql_server.sqlserver.id
    subresource_names              = ["sqlServer"]
  }
  depends_on = [
    azurerm_mssql_server.sqlserver
  ]
}

data "azurerm_private_endpoint_connection" "peconn" {
  name                = azurerm_private_endpoint.pe.name
  resource_group_name = azurerm_resource_group.rg.name
  depends_on = [
    azurerm_private_endpoint.pe
  ]
}

resource "azurerm_private_dns_a_record" "dnsrecord" {
  name                = lower(azurerm_mssql_server.sqlserver.name)
  zone_name           = azurerm_private_dns_zone.dnszone.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [data.azurerm_private_endpoint_connection.peconn.private_service_connection.0.private_ip_address]
  depends_on = [
    azurerm_mssql_server.sqlserver
  ]
}
