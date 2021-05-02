variable "db_remote_state_bucket" {
  description = "The name of the S3 bucket for the database's remote state"
  type = string
  default = null
}

variable "db_remote_state_key" {
  description = "The path for the database's remote state in S3"
  type = string
  default = null
}

variable "live_ami" {
  description = "The AMI used by the initial LC"
  type = string
}

variable "cluster_name" {
  description = "The name to use for all the cluster resources"
  type = string
}

variable "instance_type" {
  description = "The type of EC2 instances to run"
  type = string
}

variable "min_size_asg" {
  description = "The minimum number of EC2 instances in the ASG"
  type = number
}

variable "max_size_asg" {
  description = "The maximum number of EC2 instances in the ASG"
  type = number
}

variable "custom_tags" {
  description = "Custom tags propagated to instances launched by the ASG"
  type = map(string)
  default = {}
}

variable "scheduled_actions" {
  description = "Enables or disables ASG scheduled actions"
  type = bool
}

variable "alb_name" {
  description = "The name to use for the ALB"
  type = string
}

# Optional input vars, used for dependency injections on example tests

variable "vpc_id" {
  description = "The ID of the VPC to deploy into"
  type = string
  default = null
}

variable "subnet_ids" {
  description = "The IDs fo the subnets to deploy into"
  type = list(string)
  default = null
}

variable "mysql_config" {
  description = "The config for the MySQL DB"
  type = object ({
    endpoint = string
    port = number
  })
  default = null
}
