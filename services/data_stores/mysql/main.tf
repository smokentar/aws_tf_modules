resource "aws_db_instance" "initial_db" {
  identifier_prefix = "${var.db_instance_environment}-db-"
  engine            = "mysql"
  allocated_storage = 10
  instance_class    = "db.t2.micro"
  name              = "initial_database"
  username          = local.db_username
  password          = local.db_password

  skip_final_snapshot = true

  tags = merge(local.standard_tags, var.custom_tags)
}
