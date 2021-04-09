/* #delete if works
variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type = number
  default = 8080
}
variable "alb_http_port" {
  description = "HTTP port for ALB"
  default = 80
}
variable "not_found" {
  description = "404: resource not found"
  default = 404
}
*/

variable "cluster_name" {
  description = "The name to use for all the cluster resources"
  type = string
}

variable "db_remote_state_bucket" {
  description = "The name of the S3 bucket for the database's remote state"
  type = string
}

variable "db_remote_state_key" {
  description = "The path for the database's remote state in S3"
  type = string
}

variable "instance_type" {
  description = "The type of EC2 instances to run"
  type = string
}

variable "min_size_asg" {
  description = "he minimum number of EC2 instances in the ASG"
  type = number
}

variable "max_size_asg" {
  description = "The maximum number of EC2 instances in the ASG"
  type = number
}
