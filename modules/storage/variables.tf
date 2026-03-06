variable "project" { type = string }
variable "environment" { type = string }
variable "location" { type = string }
variable "resource_group_name" {
  type = string
}
variable "tags" {
  type    = map(string)
  default = {}
}

variable "config" {
  type = object({
    account_tier             = string
    account_replication_type = string
    containers               = list(string)
  })
}
