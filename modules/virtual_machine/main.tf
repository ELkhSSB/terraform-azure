# ============================================
# MODULE VIRTUAL MACHINE (Linux ou Windows)
# NIC + Public IP (optionnel) + VM
# ============================================

resource "random_password" "vm_password" {
  length           = 20
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "azurerm_public_ip" "this" {
  count               = var.enable_public_ip ? 1 : 0
  name                = "pip-${var.config.name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_network_interface" "this" {
  name                = "nic-${var.config.name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.enable_public_ip ? azurerm_public_ip.this[0].id : null
  }
}

# --- VM LINUX ---
resource "azurerm_linux_virtual_machine" "this" {
  count = var.config.os_type == "linux" ? 1 : 0

  name                  = "vm-${var.config.name}-${var.environment}"
  location              = var.location
  resource_group_name   = var.resource_group_name
  size                  = var.config.size
  admin_username        = var.config.admin_username
  network_interface_ids = [azurerm_network_interface.this.id]
  tags                  = var.tags

  admin_ssh_key {
    username   = var.config.admin_username
    public_key = var.ssh_public_key != "" ? var.ssh_public_key : tls_private_key.ssh[0].public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = var.config.disk_size_gb
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }
}

# Générer une clé SSH si aucune fournie
resource "tls_private_key" "ssh" {
  count     = var.config.os_type == "linux" && var.ssh_public_key == "" ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

# --- VM WINDOWS ---
resource "azurerm_windows_virtual_machine" "this" {
  count = var.config.os_type == "windows" ? 1 : 0

  name                  = "vm-${var.config.name}-${var.environment}"
  location              = var.location
  resource_group_name   = var.resource_group_name
  size                  = var.config.size
  admin_username        = var.config.admin_username
  admin_password        = random_password.vm_password.result
  network_interface_ids = [azurerm_network_interface.this.id]
  tags                  = var.tags

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = var.config.disk_size_gb
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }
}
