variable "environment" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "aad_admin_object_id" {
  type    = string
  default = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "config" {
  type = object({
    server_name  = string
    db_name      = string
    admin_login  = string
    sku_name     = string
    max_size_gb  = number
  })
}

variable "allowed_ip_rules" {
  type = map(object({
    start_ip = string
    end_ip   = string
  }))
  default = {}
}
