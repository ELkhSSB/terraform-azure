# ============================================
# MODULE DATABASE - Azure SQL Server + Database
# ============================================

resource "random_password" "sql_admin" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "azurerm_mssql_server" "this" {
  name                         = "${var.config.server_name}-${var.environment}"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.config.admin_login
  administrator_login_password = random_password.sql_admin.result
  minimum_tls_version          = "1.2"

  azuread_administrator {
    login_username = "AzureAD Admin"
    object_id      = var.aad_admin_object_id
  }

  tags = var.tags
}

resource "azurerm_mssql_database" "this" {
  name         = var.config.db_name
  server_id    = azurerm_mssql_server.this.id
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  sku_name     = var.config.sku_name
  max_size_gb  = var.config.max_size_gb

  short_term_retention_policy {
    retention_days           = 7
    backup_interval_in_hours = 12
  }

  tags = var.tags
}

# Firewall: Autoriser les services Azure
resource "azurerm_mssql_firewall_rule" "azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.this.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Firewall: IP autorisées (ex: bureau, VPN)
resource "azurerm_mssql_firewall_rule" "allowed_ips" {
  for_each = var.allowed_ip_rules

  name             = each.key
  server_id        = azurerm_mssql_server.this.id
  start_ip_address = each.value.start_ip
  end_ip_address   = each.value.end_ip
}
