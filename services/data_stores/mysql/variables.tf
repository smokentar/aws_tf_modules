variable "db_instance_environment" {
  description = "The environment of the database"
  type = string
}

variable "custom_tags" {
  description = "Custom tags for the DB instance"
  type = map(string)
  default = {}
}
