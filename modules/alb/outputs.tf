output "lb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "lb_target_group_arn" {
  description = "The ARN of the load balancer target group"
  value       = aws_lb_target_group.main.arn
}

output "listener_arn" {
  description = "The ARN of the load balancer listener"
  value       = aws_lb_listener.http.arn
}
