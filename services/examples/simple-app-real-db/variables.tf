variable "mysql_config" {
  description = "The config for the MySQL DB"

  type = object({
    endpoint = string
    port     = number
  })

  default = {
    endpoint = "example-db"
    port     = "12345"
  }
}

variable "alb_name" {
  description = "The name to use for the ALB"
  type        = string
  default     = "alb-example"
}

variable "db_remote_state_bucket" {
  description = "The name of the S3 bucket for the database's remote state"
  type        = string
}

variable "db_remote_state_key" {
  description = "The path for the database's remote state in S3"
  type        = string
}
