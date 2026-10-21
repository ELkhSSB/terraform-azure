# ============================================
# MODULE KEY VAULT
# ============================================

data "azurerm_client_config" "current" {}

resource "random_string" "suffix" {
  length  = 4
  upper   = false
  special = false
}

resource "azurerm_key_vault" "this" {
  name                        = "kv-${var.project}-${var.environment}-${random_string.suffix.result}"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = var.sku

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions     = ["Get", "List", "Create", "Delete", "Update", "Purge", "Recover"]
    secret_permissions  = ["Get", "List", "Set", "Delete", "Purge", "Recover"]
    storage_permissions = ["Get", "List"]
  }

  tags = var.tags
}

# Accès pour les identités managées (VMs, etc.)
resource "azurerm_key_vault_access_policy" "identities" {
  for_each = var.managed_identity_ids

  key_vault_id = azurerm_key_vault.this.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = each.value

  secret_permissions = ["Get", "List"]
}

# Secrets non sensibles (noms de serveurs, endpoints, etc.)
resource "azurerm_key_vault_secret" "plain" {
  for_each = var.plain_secrets

  name         = each.key
  value        = each.value
  key_vault_id = azurerm_key_vault.this.id
  tags         = var.tags

  lifecycle {
    ignore_changes = [value]
  }
}

# Secret : mot de passe base de données
resource "azurerm_key_vault_secret" "db_password" {
  count        = var.db_password != "" ? 1 : 0
  name         = "db-admin-password"
  value        = var.db_password
  key_vault_id = azurerm_key_vault.this.id
  tags         = var.tags

  lifecycle {
    ignore_changes = [value]
  }
}

# Secret : connection string base de données
resource "azurerm_key_vault_secret" "db_connection_string" {
  count        = var.db_connection_string != "" ? 1 : 0
  name         = "db-connection-string"
  value        = var.db_connection_string
  key_vault_id = azurerm_key_vault.this.id
  tags         = var.tags

  lifecycle {
    ignore_changes = [value]
  }
}

# Secret : clé SSH de la VM
resource "azurerm_key_vault_secret" "vm_ssh_key" {
  count        = var.vm_ssh_private_key != "" ? 1 : 0
  name         = "vm-ssh-private-key"
  value        = var.vm_ssh_private_key
  key_vault_id = azurerm_key_vault.this.id
  tags         = var.tags

  lifecycle {
    ignore_changes = [value]
  }
}
