locals {
  first_public_key    = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDSXiC8mWaQrm/qniBBJ1YcxdvVgUvVAp5u2AX62H0SeN5IYrTEAfcXZ8jljfmRYOcPYa28MUiwVmzm6pdyE5eYuE472EEx92iK6O86Gr6MNqKWOWmoHMD6W//kAMm1Heeud+1OrRy86vNCiLimUvTWpNJb+j56Uc73ftdeD2dzKzp33Eq4jqoIcG056yX3z3He59lzyFRtIsVeKB+XdJ7fIJ0pNfF/A6oZRqHprnf1h9BklFhwQr8VZCuHwa/zteFIyo2wgvSEIFgu8lFDJeslP4LI0RvQUNoPZBBhRsSlCt2K/ly5GtKorLgCG0yDgfuhAAu2SUmde871pfJS35QV rsa-key-20220906"
}

resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = var.vmss_name
  resource_group_name = var.rg_name
  location            = var.rg_location
  sku                 = var.vmss_sku
  instances           = var.vmss_instance_count
  admin_username      = var.vmss_login_username
  zone_balance        = true
  zones               = ["1", "2"]

  admin_ssh_key {
    username   = var.vmss_login_username
    public_key = local.first_public_key
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "${var.vmss_name}-nic"
    primary = true

    ip_configuration {
      name                                         = "internal"
      primary                                      = true
      subnet_id                                    = var.subnet_id
      application_gateway_backend_address_pool_ids = [var.app_gateway_bind_be_pool]
    }
  }
}
