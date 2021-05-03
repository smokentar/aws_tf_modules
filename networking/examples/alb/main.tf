provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

module "alb" {
  source = "../../alb"

  alb_name   = var.alb_name
  subnet_ids = data.aws_subnet_ids.default.ids
}
