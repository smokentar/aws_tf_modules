variable "cluster_name" {
  description = "The name to use for all the cluster resources"
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

variable "live_ami" {
  description = "The AMI used by the initial LC"
  type = string
}

variable "subnet_ids" {
  description = "The subnet IDs to deploy to"
  type = list(string)
}

variable "target_group_arns" {
  description = "The ARNs of ELB target groups in which to register"
  type = list(string)
  default = []
}

variable "health_check_type" {
  description = "The type of health check to perform. Must be one of: EC2, ELB."
  type = string
  default ="EC2"
}

variable "user_data" {
  description = "The User Data script to run against each instance at boot"
  type = string
  default = null
}
