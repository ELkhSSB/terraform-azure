# ============================================
# MODULE STORAGE ACCOUNT
# Blob containers + lifecycle policy
# ============================================

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "azurerm_storage_account" "this" {
  name                     = "st${var.project}${var.environment}${random_string.suffix.result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.config.account_tier
  account_replication_type = var.config.account_replication_type
  min_tls_version          = "TLS1_2"

  blob_properties {
    versioning_enabled = true
    delete_retention_policy {
      days = 7
    }
    container_delete_retention_policy {
      days = 7
    }
  }

  tags = var.tags
}

resource "azurerm_storage_container" "this" {
  for_each = toset(var.config.containers)

  name                  = each.value
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}

# Lifecycle: déplacer vers Cool après 30j, supprimer après 90j (logs)
resource "azurerm_storage_management_policy" "this" {
  storage_account_id = azurerm_storage_account.this.id

  rule {
    name    = "lifecycle-logs"
    enabled = true

    filters {
      prefix_match = ["logs/"]
      blob_types   = ["blockBlob"]
    }

    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than    = 30
        tier_to_archive_after_days_since_modification_greater_than = 60
        delete_after_days_since_modification_greater_than          = 90
      }
    }
  }
}
