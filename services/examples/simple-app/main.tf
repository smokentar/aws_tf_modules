provider "aws" {
  region = "us-east-1"
}

module "web_cluster" {
  # This cluster will host a simple app
  source = "github.com/smokentar/aws_tf_modules//services/simple-app?ref=staging"

  # Pass in staging-specific variables
  cluster_name = "web-example"
  live_ami = "ami-013f17f36f8b1fefb"

  mysql_config = var.mysql_config

  min_size_asg = 2
  max_size_asg = 2
  instance_type  = "t2.micro"

  scheduled_actions = false

  custom_tags = {
    Environment = "Staging"
    Type = "immutable"
  }
}
