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

variable "custom_tags" {
  description = "Custom tags propagated to instances launched by the ASG"
  type = map(string)
  default = {}
}

variable "scheduled_actions" {
  description = "Enables or disables ASG scheduled actions"
  type = bool
}
