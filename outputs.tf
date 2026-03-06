# ================================================================
# OUTPUTS — Toutes les sorties importantes
# ================================================================

output "resource_group_name" {
  value = module.resource_group.name
}

output "networking" {
  value = var.create_networking ? {
    vnet_id      = module.networking[0].vnet_id
    vnet_name    = module.networking[0].vnet_name
    subnet_ids   = module.networking[0].subnet_ids
  } : null
}

output "virtual_machine" {
  value = var.create_vm ? {
    vm_id      = module.virtual_machine[0].vm_id
    vm_name    = module.virtual_machine[0].vm_name
    private_ip = module.virtual_machine[0].private_ip
    public_ip  = module.virtual_machine[0].public_ip
  } : null
}

output "vm_ssh_private_key" {
  value     = var.create_vm ? module.virtual_machine[0].ssh_private_key : null
  sensitive = true
}

output "storage" {
  value = var.create_storage ? {
    account_name  = module.storage[0].storage_account_name
    blob_endpoint = module.storage[0].primary_blob_endpoint
    containers    = module.storage[0].container_names
  } : null
}

output "database" {
  value = var.create_database ? {
    server_fqdn      = module.database[0].server_fqdn
    database_name    = module.database[0].database_name
    connection_string = module.database[0].connection_string
  } : null
}

output "keyvault" {
  value = var.create_keyvault ? {
    name      = module.keyvault[0].key_vault_name
    vault_uri = module.keyvault[0].vault_uri
  } : null
}

output "monitoring" {
  value = var.create_monitoring ? {
    workspace_name    = module.monitoring[0].workspace_name
    app_insights_name = module.monitoring[0].app_insights_name
  } : null
}
