output "server_name" {
  value = azurerm_mssql_server.this.name
}

output "server_fqdn" {
  value = azurerm_mssql_server.this.fully_qualified_domain_name
}

output "database_name" {
  value = azurerm_mssql_database.this.name
}

output "admin_login" {
  value = azurerm_mssql_server.this.administrator_login
}

output "admin_password" {
  value     = random_password.sql_admin.result
  sensitive = true
}

output "connection_string" {
  value = "Server=tcp:${azurerm_mssql_server.this.fully_qualified_domain_name},1433;Database=${azurerm_mssql_database.this.name};User ID=${azurerm_mssql_server.this.administrator_login};Encrypt=True;"
}
