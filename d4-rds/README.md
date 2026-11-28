D4. RDS PostgreSQL + Secrets Manager

```bash
terraform init
terraform validate
terraform plan
terraform apply     # RDS 생성에 5~10분
terraform output db_endpoint
terraform destroy   # 시크릿 예약 삭제 없이 바로 삭제되도록 설정됨
```

- [x]  DB 보안그룹: 앱 보안그룹에서 오는 5432만 허용
- [x]  DB 서브넷 그룹: private 서브넷 2개
- [x]  RDS PostgreSQL 생성 (`publicly_accessible = false`, Single-AZ)
- [x]  `random_password`로 비밀번호 생성 (코드에 평문 없음)
- [x]  Secrets Manager에 `username / password / host / port / dbname` JSON 저장
- [x]  콘솔에서 Publicly accessible: No 확인
- [x]  destroy 후 RDS, 시크릿, ALB, EC2, NAT, EIP 잔여 리소스 확인

**키포인트**
- DB는 private 서브넷에 두고, 공인 IP도 주지 않고, 앱 보안그룹에서 오는 5432만 받는다. 외부 노출을 이중으로 막는다.
- 비밀번호는 `random_password`로 만들어 Secrets Manager에 보관한다. state에는 평문으로 남으므로 `state show`로 출력하거나 git에 올리지 않는다.
- `jsonencode`는 객체를 JSON 문자열로 바꾼다. Secrets Manager에는 문자열이 필요하다.
