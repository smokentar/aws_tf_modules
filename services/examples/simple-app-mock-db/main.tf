provider "aws" {
  region = "us-east-1"
}

module "web_cluster" {
  # This cluster will host a simple app
  source = "../../simple-app"

  # Pass in name of alb to allow parallel testing based on conditional var in simple-app
  alb_name = var.alb_name

  # Pass in example-specific variables
  cluster_name = "web-example"
  live_ami     = "ami-013f17f36f8b1fefb"

  mysql_config = var.mysql_config

  min_size_asg  = 2
  max_size_asg  = 2
  instance_type = "t2.micro"

  scheduled_actions = false

  custom_tags = {
    Environment = "Automated testing"
    Type        = "immutable"
  }
}
