# ================================================================
# OUTPUTS — Séparés entre données publiques et sensibles
# ================================================================

# ---------------------------------------------------------------
# SAFE — Affichés normalement après terraform apply
# ---------------------------------------------------------------
output "resource_group_name" {
  description = "Nom du resource group"
  value       = module.resource_group.name
}

output "networking" {
  description = "Informations réseau (non sensibles)"
  value = var.create_networking ? {
    vnet_id    = module.networking[0].vnet_id
    vnet_name  = module.networking[0].vnet_name
    subnet_ids = module.networking[0].subnet_ids
  } : null
}

output "virtual_machine" {
  description = "Informations VM (non sensibles)"
  value = var.create_vm ? {
    vm_id      = module.virtual_machine[0].vm_id
    vm_name    = module.virtual_machine[0].vm_name
    private_ip = module.virtual_machine[0].private_ip
    public_ip  = module.virtual_machine[0].public_ip
  } : null
}

output "storage" {
  description = "Informations Storage (non sensibles)"
  value = var.create_storage ? {
    account_name  = module.storage[0].storage_account_name
    blob_endpoint = module.storage[0].primary_blob_endpoint
    containers    = module.storage[0].container_names
  } : null
}

output "database" {
  description = "Informations base de données (non sensibles)"
  value = var.create_database ? {
    server_fqdn   = module.database[0].server_fqdn
    database_name = module.database[0].database_name
    admin_login   = module.database[0].admin_login
  } : null
}

output "keyvault" {
  description = "Informations Key Vault (non sensibles)"
  value = var.create_keyvault ? {
    name      = module.keyvault[0].key_vault_name
    vault_uri = module.keyvault[0].vault_uri
  } : null
}

output "monitoring" {
  description = "Informations monitoring (non sensibles)"
  value = var.create_monitoring ? {
    workspace_name    = module.monitoring[0].workspace_name
    app_insights_name = module.monitoring[0].app_insights_name
  } : null
}

# ---------------------------------------------------------------
# SENSIBLE — Jamais affichés automatiquement
# Récupérer avec : terraform output -raw <nom>
# ---------------------------------------------------------------
output "vm_ssh_private_key" {
  description = "Clé SSH privée de la VM — terraform output -raw vm_ssh_private_key"
  value       = var.create_vm ? module.virtual_machine[0].ssh_private_key : null
  sensitive   = true
}

output "vm_admin_password" {
  description = "Mot de passe admin VM Windows — terraform output -raw vm_admin_password"
  value       = var.create_vm ? module.virtual_machine[0].admin_password : null
  sensitive   = true
}

output "db_admin_password" {
  description = "Mot de passe SQL admin — terraform output -raw db_admin_password"
  value       = var.create_database ? module.database[0].admin_password : null
  sensitive   = true
}

output "db_connection_string" {
  description = "Connection string SQL — terraform output -raw db_connection_string"
  value       = var.create_database ? module.database[0].connection_string : null
  sensitive   = true
}

output "storage_access_key" {
  description = "Clé d'accès Storage — terraform output -raw storage_access_key"
  value       = var.create_storage ? module.storage[0].primary_access_key : null
  sensitive   = true
}
