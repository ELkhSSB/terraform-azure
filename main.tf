# ================================================================
#  MAIN.TF — dev AZURE
#  Tu n'as qu'à activer/désactiver les modules avec true/false
#  et ajuster les variables dans variables.tf (ou terraform.tfvars)
# ================================================================

locals {
  project     = var.project
  environment = var.environment
  location    = var.location

  common_tags = merge(var.tags, {
    environment = var.environment
    project     = var.project
    managed_by  = "terraform"
  })
}

# ----------------------------------------------------------------
# 1. RESOURCE GROUP — Toujours créé en premier
# ----------------------------------------------------------------
module "resource_group" {
  source   = "./modules/resource_group"
  name     = "rg-${local.project}-${local.environment}"
  location = local.location
  tags     = local.common_tags
}

# ----------------------------------------------------------------
# 2. NETWORKING — VNet, Subnets, NSG
# ----------------------------------------------------------------
module "networking" {
  count  = var.create_networking ? 1 : 0
  source = "./modules/networking"

  project             = local.project
  environment         = local.environment
  location            = local.location
  resource_group_name = module.resource_group.name
  address_space       = var.vnet_address_space
  subnets             = var.subnets
  allowed_mgmt_cidr   = "154.146.250.207/32"
  tags                = local.common_tags
}

# ----------------------------------------------------------------
# 3. VIRTUAL MACHINE — Linux ou Windows
# ----------------------------------------------------------------
module "virtual_machine" {
  count  = var.create_vm ? 1 : 0
  source = "./modules/virtual_machine"

  environment         = local.environment
  location            = local.location
  resource_group_name = module.resource_group.name
  config              = var.vm_config
  subnet_id           = var.create_networking ? module.networking[0].subnet_ids[var.vm_subnet_name] : ""
  enable_public_ip    = var.vm_enable_public_ip
  ssh_public_key      = var.vm_ssh_public_key
  tags                = local.common_tags
}

# ----------------------------------------------------------------
# 4. STORAGE ACCOUNT — Blob containers
# ----------------------------------------------------------------
module "storage" {
  count  = var.create_storage ? 1 : 0
  source = "./modules/storage"

  project             = local.project
  environment         = local.environment
  location            = local.location
  resource_group_name = module.resource_group.name
  config              = var.storage_config
  tags                = local.common_tags
}

# ----------------------------------------------------------------
# 5. BASE DE DONNÉES — Azure SQL Server + Database
# ----------------------------------------------------------------
module "database" {
  count  = var.create_database ? 1 : 0
  source = "./modules/database"

  environment         = local.environment
  location            = local.location
  resource_group_name = module.resource_group.name
  config              = var.database_config
  aad_admin_object_id = var.aad_admin_object_id
  allowed_ip_rules    = var.allowed_ip_rules
  tags                = local.common_tags
}

# ----------------------------------------------------------------
# 6. KEY VAULT — Secrets & certificats
#    Activer : create_keyvault = true dans variables.tf
# ----------------------------------------------------------------
module "keyvault" {
  count  = var.create_keyvault ? 1 : 0
  source = "./modules/keyvault"

  project             = local.project
  environment         = local.environment
  location            = local.location
  resource_group_name = module.resource_group.name
  sku                 = var.keyvault_sku

  # Identités managées des VMs
  managed_identity_ids = var.create_vm ? {
    vm-identity = module.virtual_machine[0].principal_id
  } : {}

  # Secrets NON sensibles — safe pour for_each
  plain_secrets = {
    "db-server-fqdn" = var.create_database ? module.database[0].server_fqdn : ""
    "db-name"        = var.create_database ? module.database[0].database_name : ""
  }

  # Secrets SENSIBLES — passés individuellement
  db_password          = var.create_database ? module.database[0].admin_password : ""
  db_connection_string = var.create_database ? module.database[0].connection_string : ""
  vm_ssh_private_key   = var.create_vm ? coalesce(module.virtual_machine[0].ssh_private_key, "") : ""

  tags = local.common_tags
}

# ----------------------------------------------------------------
# 7. MONITORING — Log Analytics + Application Insights + Alertes
#    Activer : create_monitoring = true dans variables.tf
# ----------------------------------------------------------------
module "monitoring" {
  count  = var.create_monitoring ? 1 : 0
  source = "./modules/monitoring"

  project             = local.project
  environment         = local.environment
  location            = local.location
  resource_group_name = module.resource_group.name
  retention_days      = var.log_retention_days
  vm_resource_id      = var.create_vm ? module.virtual_machine[0].vm_id : ""
  tags                = local.common_tags
}

