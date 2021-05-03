output "alb_dns_name" {
  description = "The DNS endpoint of the ALB"
  value       = module.alb.alb_dns_name
}
