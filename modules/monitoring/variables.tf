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

variable "retention_days" {
  type    = number
  default = 30
}

variable "app_insights_type" {
  type    = string
  default = "web"
}

variable "vm_resource_id" {
  type    = string
  default = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}
