output "vm_id" {
  value = var.config.os_type == "linux" ? (
    length(azurerm_linux_virtual_machine.this) > 0 ? azurerm_linux_virtual_machine.this[0].id : null
  ) : (
    length(azurerm_windows_virtual_machine.this) > 0 ? azurerm_windows_virtual_machine.this[0].id : null
  )
}

output "vm_name" {
  value = var.config.os_type == "linux" ? (
    length(azurerm_linux_virtual_machine.this) > 0 ? azurerm_linux_virtual_machine.this[0].name : null
  ) : (
    length(azurerm_windows_virtual_machine.this) > 0 ? azurerm_windows_virtual_machine.this[0].name : null
  )
}

output "private_ip" {
  value = azurerm_network_interface.this.private_ip_address
}

output "public_ip" {
  value = var.enable_public_ip ? azurerm_public_ip.this[0].ip_address : null
}

output "admin_password" {
  value     = var.config.os_type == "windows" ? random_password.vm_password.result : null
  sensitive = true
}

output "ssh_private_key" {
  value     = var.config.os_type == "linux" && var.ssh_public_key == "" ? tls_private_key.ssh[0].private_key_pem : null
  sensitive = true
}

output "principal_id" {
  description = "Managed Identity principal ID"
  value = var.config.os_type == "linux" ? (
    length(azurerm_linux_virtual_machine.this) > 0 ? azurerm_linux_virtual_machine.this[0].identity[0].principal_id : null
  ) : (
    length(azurerm_windows_virtual_machine.this) > 0 ? azurerm_windows_virtual_machine.this[0].identity[0].principal_id : null
  )
}
