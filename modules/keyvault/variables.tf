variable "project"             { type = string }
variable "environment"         { type = string }
variable "location"            { type = string }
variable "resource_group_name" { type = string }
variable "sku"                 { type = string; default = "standard" }
variable "tags"                { type = map(string); default = {} }
variable "managed_identity_ids" { type = map(string); default = {} }
variable "secrets"              { type = map(string); default = {}; sensitive = true }
