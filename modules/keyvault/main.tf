# ============================================
# MODULE KEY VAULT
# Stockage sécurisé des secrets + accès policies
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
  purge_protection_enabled    = false  # true en prod
  sku_name                    = var.sku

  # Accès Terraform (le caller courant)
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

# Stocker les secrets passés en variable
resource "azurerm_key_vault_secret" "this" {
  for_each = var.secrets

  name         = each.key
  value        = each.value
  key_vault_id = azurerm_key_vault.this.id
  tags         = var.tags
}
