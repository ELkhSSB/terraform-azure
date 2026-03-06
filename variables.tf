# ============================================
# VARIABLES GLOBALES - dev AZURE
# ============================================

variable "environment" {
  description = "Nom de l'environnement"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Région Azure"
  type        = string
  default     = "francecentral"
}

variable "project" {
  description = "Nom du projet"
  type        = string
  default     = "monprojet"
}

variable "tags" {
  description = "Tags communs appliqués à toutes les ressources"
  type        = map(string)
  default     = {}
}

# --- Networking ---
variable "create_networking" {
  description = "Créer le module réseau (VNet, Subnets, NSG)"
  type        = bool
  default     = false
}

variable "vnet_address_space" {
  description = "Plage d'adresses du VNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnets" {
  description = "Map des subnets à créer"
  type = map(object({
    address_prefix = string
  }))
  default = {
    subnet-app = { address_prefix = "10.0.1.0/24" }
    subnet-db  = { address_prefix = "10.0.2.0/24" }
    subnet-mgmt = { address_prefix = "10.0.3.0/24" }
  }
}

# --- Virtual Machine ---
variable "create_vm" {
  description = "Créer le module VM"
  type        = bool
  default     = false
}

variable "vm_config" {
  description = "Configuration de la VM"
  type = object({
    name           = string
    size           = string
    admin_username = string
    os_type        = string # "linux" ou "windows"
    disk_size_gb   = number
  })
  default = {
    name           = "vm-app"
    size           = "Standard_B2s"
    admin_username = "azureuser"
    os_type        = "linux"
    disk_size_gb   = 30
  }
}

variable "vm_subnet_name" {
  description = "Nom du subnet pour la VM"
  type        = string
  default     = "subnet-app"
}

# --- Storage ---
variable "create_storage" {
  description = "Créer le module Storage Account"
  type        = bool
  default     = false
}

variable "storage_config" {
  description = "Configuration du Storage Account"
  type = object({
    account_tier             = string
    account_replication_type = string
    containers               = list(string)
  })
  default = {
    account_tier             = "Standard"
    account_replication_type = "LRS"
    containers               = ["data", "logs", "backups"]
  }
}

# --- Database ---
variable "create_database" {
  description = "Créer le module Azure SQL"
  type        = bool
  default     = false
}

variable "database_config" {
  description = "Configuration de la base de données"
  type = object({
    server_name    = string
    db_name        = string
    admin_login    = string
    sku_name       = string
    max_size_gb    = number
  })
  default = {
    server_name    = "sql-server"
    db_name        = "db-dev"
    admin_login    = "sqladmin"
    sku_name       = "S1"
    max_size_gb    = 32
  }
}

# --- Key Vault ---
variable "create_keyvault" {
  description = "Créer le module Key Vault"
  type        = bool
  default     = true
}

variable "keyvault_sku" {
  description = "SKU du Key Vault (standard ou premium)"
  type        = string
  default     = "standard"
}

# --- Monitoring ---
variable "create_monitoring" {
  description = "Créer le module Monitoring (Log Analytics + App Insights)"
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "Rétention des logs en jours"
  type        = number
  default     = 30
}

variable "aad_admin_object_id" {
  type      = string
  default   = ""
  sensitive = true
}

variable "allowed_ip_rules" {
  type = map(object({
    start_ip = string
    end_ip   = string
  }))
  default   = {}
  sensitive = true
}