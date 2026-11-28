# 모듈 outputs.tf : 다른 모듈에 넘길 값

output "db_endpoint" {
  value = aws_db_instance.main.address
}

output "db_secret_name" {
  value = aws_secretsmanager_secret.db.name
}
output "db_secret_arn" {
  value = aws_secretsmanager_secret.db.arn
}

output "db_sg_id" {
  value = aws_security_group.db.id
}