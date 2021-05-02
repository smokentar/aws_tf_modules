variable "mysql_config" {
  description = "The config for the MySQL DB"

  type = object ({
    endpoint = string
    port = number
    })

  default = {
    endpoint = "example-db"
    port = "12345"
  }
}

variable "alb_name" {
  description = "The IDs fo the subnets to deploy into"
  type = string
  default = null
}
