# 사용자가 apply 후 값을 콘솔이나 터미널에서 보기 위한 파일
output "vpc_id" {
  value = "module.network.vpc_id"
}

output "alb_dns_name" {
  value = module.compute.alb_dns_name
}

output "db_endpoint" {
  value = module.database.db_endpoint
}

output "db_secret_name" {
  value = module.database.db_secret_name
}