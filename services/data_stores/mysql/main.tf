provider "aws" {
  region = "us-east-1"
}

data "aws_ssm_parameter" "initial-db-pw" {
  name = "initial-db-password"
}

data "aws_ssm_parameter" "initial-db-uname" {
  name = "initial-db-username"
}


resource "aws_db_instance" "initial_db" {
  identifier_prefix = "${var.db_instance_environment}-db-"
  engine = "mysql"
  allocated_storage = 10
  instance_class = "db.t2.micro"
  name = "initial_database"
  username = data.aws_ssm_parameter.initial-db-uname.value
  password = data.aws_ssm_parameter.initial-db-pw.value

  skip_final_snapshot = true

  dynamic "tags" {
    for_each = local.standard_tags

    content {
      key = tag.key
      value = tag.value
      propagate_at_launch = true
    }
  }
}
