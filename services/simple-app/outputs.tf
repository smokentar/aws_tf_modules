output "alb_dns_name" {
  description = "The DNS of the ALB"
  value = module.alb.alb_dns_name
}

output "asg_name" {
  description = "The name of the ASG"
  value = module.asg.asg_name
}

output "instance_security_group_id" {
  description = "The SG ID attached to the servers hosting the simple-app"
  value = module.asg.instance_security_group_id
}
