output "alb_dns_name" {
  description = "The DNS endpoint of the ALB"
  value = aws_lb.initial_alb.dns_name
}

output "alb_http_listener_arn" {
  description = "The ARN of the HTTP listener"
  value = aws_lb_listener.http.arn
}

output "alb_security_group_id" {
  description = "The ID of the ALB SG"
  value = aws_security_group.alb.id
}
