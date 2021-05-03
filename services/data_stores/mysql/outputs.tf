output "endpoint" {
  description = "DB endpoint"
  value       = aws_db_instance.initial_db.address
}

output "port" {
  description = "DB port"
  value       = aws_db_instance.initial_db.port
}
