provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

data "template_file" "user_data" {
  template = file("${path.module}/user-data.sh")
  vars = {
    user_data_server_port = 8080
  }
}

module "asg-example" {
  source = "../../asg-rolling-deploy"

  cluster_name = "asg-example"
  live_ami     = "ami-013f17f36f8b1fefb"

  min_size_asg  = 2
  max_size_asg  = 2
  instance_type = "t2.micro"

  scheduled_actions = false

  subnet_ids = data.aws_subnet_ids.default.ids

  custom_tags = {
    Environment = "example"
    Type        = "immutable"
  }
}
