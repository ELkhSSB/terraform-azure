variable "environment" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "subnet_id" { type = string }
variable "ssh_public_key" {
  type    = string
  default = ""
}
variable "enable_public_ip" {
  type    = bool
  default = false
}
variable "tags" {
  type    = map(string)
  default = {}
}

variable "config" {
  type = object({
    name           = string
    size           = string
    admin_username = string
    os_type        = string
    disk_size_gb   = number
  })
}
