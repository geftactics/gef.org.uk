variable "environment" {
  type = string
}

variable "domain" {
  type = string
}

variable "zone" {
  type = string
}

variable "cf_functions" {
  type    = list(string)
  default = []
}