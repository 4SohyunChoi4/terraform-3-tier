output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "alb_dns_name" {
  value = aws_lb.app.dns_name
}

output "db_endpoint" {
  value = aws_db_instance.main.address
}

output "db_secret_name" {
  value = aws_secretsmanager_secret.db.name
}