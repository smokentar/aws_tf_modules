variable "db_instance_environment" {
  description = "The environment of the database"
  type        = string
}

variable "custom_tags" {
  description = "Custom tags for the DB instance"
  type        = map(string)
  default     = {}
}

# Optional input vars, used for dependency injections on example tests

variable "db_username" {
  description = "Username for the DB"
  type        = string
  default     = null
}

variable "db_password" {
  description = "Password for the DB"
  type        = string
  default     = null
}
