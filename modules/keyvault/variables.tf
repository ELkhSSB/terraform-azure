variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "sku" {
  type    = string
  default = "standard"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "managed_identity_ids" {
  type    = map(string)
  default = {}
}

# Secrets NON sensibles — utilisables dans for_each (endpoints, noms, etc.)
variable "plain_secrets" {
  type    = map(string)
  default = {}
}

# Secrets sensibles — passés individuellement pour éviter le bug for_each
variable "db_password" {
  type      = string
  default   = ""
  sensitive = true
}

variable "db_connection_string" {
  type      = string
  default   = ""
  sensitive = true
}

variable "vm_ssh_private_key" {
  type      = string
  default   = ""
  sensitive = true
}
