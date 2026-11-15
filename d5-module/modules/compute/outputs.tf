output "app_sg_id" {
  value = aws_security_group.app.id
}

output "alb_dns_name" {
  value = aws_lb.app.dns_name
}
