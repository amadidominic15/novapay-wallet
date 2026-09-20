variable "project" {
  type    = string
  default = "novapay-wallet"
}

variable "environment" {
  type    = string
  default = "staging"
}

variable "db_password" {
  description = "password for app database"
  type        = string
  sensitive   = true
}