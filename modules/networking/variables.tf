variable "project"             { type = string }
variable "environment"         { type = string }
variable "location"            { type = string }
variable "resource_group_name" { type = string }
variable "address_space"       { type = list(string); default = ["10.0.0.0/16"] }
variable "allowed_mgmt_cidr"   { type = string;       default = "*" }
variable "tags"                { type = map(string);  default = {} }

variable "subnets" {
  type = map(object({ address_prefix = string }))
}
