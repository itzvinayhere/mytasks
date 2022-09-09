rg_name = "demo-rg"

rg_location = "eastus"

vnet_name = "demo-vnet"

vnet_cidr = ["10.0.0.0/16"]

subnet_gtw_name = "demo-gtw-subnet"

subnet_gtw_cidr = ["10.0.1.0/24"]

nsg_web_name = "demo-web-nsg"

subnet_web_name = "demo-web-subnet"

subnet_web_cidr = ["10.0.2.0/24"]

nsg_svc_name = "demo-svc-nsg"

subnet_svc_name = "demo-svc-subnet"

subnet_svc_cidr = ["10.0.3.0/24"]

subnet_pep_name = "demo-pep-subnet"

subnet_pep_cidr = ["10.0.4.0/24"]

vmss_web_name = "demo-web-vmss"

vmss_svc_name = "demo-svc-vmss"

vmss_sku = "Standard_B1ms"

vmss_login_username = "adminuser"

vmss_instance_count = 1

pip_name = "demo-app-gtw-pip"

app_gateway_name = "demo-app-gtw"

sql_server_name = "demo-nvk-sql-server"

sql_server_user = "sqluser"

sql_server_password = "P@$$word_123"

sql_db_name = "demo-sql-db"

dns_zone_name = "privatelink.database.windows.net"

dns_zone_link_name = "sql-db-ntw-link"