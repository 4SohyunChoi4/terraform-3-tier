resource "aws_security_group" "db" {
  name        = "${var.project}-db-sg"
  description = "PostgreSQL from app only"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  tags = { Name = "${var.project}-db-sg" }
}

# DB를 private 서브넷에 두기 위한 서브넷 그룹
resource "aws_db_subnet_group" "db" {
  name       = "${var.project}-db-subnets"
  subnet_ids = aws_subnet.private[*].id

  tags = { Name = "${var.project}-db-subnets" }
}

# 비밀번호는 코드에 쓰지 않고 랜덤으로 생성
resource "random_password" "db" {
  length  = 20
  special = false
}

resource "aws_db_instance" "main" {
  identifier             = "${var.project}-db"
  engine                 = "postgres"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = "appdb"
  username               = "dbadmin"
  password               = random_password.db.result
  db_subnet_group_name   = aws_db_subnet_group.db.name
  vpc_security_group_ids = [aws_security_group.db.id]

  publicly_accessible     = false
  multi_az                = false
  backup_retention_period = 0 # 운영에서는 기본값 이상으로
  deletion_protection     = false
  skip_final_snapshot     = true # 실습 후 destroy 빨리 되도록 함

  tags = { Name = "${var.project}-db" }
}

# 접속 정보를 Secret Manager에 저장
resource "aws_secretsmanager_secret" "db" {
  name                    = "${var.project}/db-credentials"
  recovery_window_in_days = 0 # 바로 삭제 가능, 안 하면 destroy 후 같은 재생성이 막힘

  tags = { Name = "${var.project}-db-secret" }
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    username = aws_db_instance.main.username
    password = random_password.db.result
    host     = aws_db_instance.main.address
    port     = aws_db_instance.main.port
    dbname   = aws_db_instance.main.db_name
  })
}
