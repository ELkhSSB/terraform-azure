output "storage_account_name" { value = azurerm_storage_account.this.name }
output "storage_account_id" { value = azurerm_storage_account.this.id }
output "primary_blob_endpoint" { value = azurerm_storage_account.this.primary_blob_endpoint }
output "primary_access_key" {
  value     = azurerm_storage_account.this.primary_access_key
  sensitive = true
}
output "container_names" { value = [for c in azurerm_storage_container.this : c.name] }
