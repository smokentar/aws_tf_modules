output "asg_name" {
  description = "The name of the ASG"
  value       = aws_autoscaling_group.initial_asg.name
}

output "instance_security_group_id" {
  description = "The ID of the SG attached to the instances"
  value       = aws_security_group.initial_sg.id
}
