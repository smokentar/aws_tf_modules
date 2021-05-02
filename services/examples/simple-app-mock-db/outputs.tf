output "alb_dns_name" {
  description = "The DNS endpoint of the ALB"
  value = module.web_cluster.alb_dns_name
}
