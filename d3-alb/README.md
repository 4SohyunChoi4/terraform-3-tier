D3. ALB + Target Group + ASG (보안그룹 체이닝)

```bash
terraform init
terraform plan
terraform apply
terraform output alb_dns_name
curl http://$(terraform output -raw alb_dns_name)
terraform destroy   # ALB, EC2, NAT 과금 주의
```

- [x]  보안그룹 2개: ALB(80 from 인터넷), App(80 from ALB 보안그룹만)
- [x]  ALB, Target Group, Listener 생성 (헬스체크 `/`, 200)
- [x]  Launch Template + ASG를 private 서브넷에 배치하고 Target Group에 연결
- [x]  `user_data.sh`로 nginx 설치 및 호스트 이름 응답
- [x]  ALB DNS로 접속해서 여러 번 응답 확인 (`Hello from ip-...`)
- [x]  인스턴스 하나 Terminate 후 ASG가 자동 복구하는지 확인 (선택)

**키포인트**
- 앱 보안그룹은 CIDR이 아니라 ALB 보안그룹 ID에서 오는 트래픽만 허용한다. IP가 바뀌어도 규칙이 깨지지 않는다.
- 인스턴스는 private이라 공인 IP가 없고, `dnf install`은 NAT를 거쳐 나간다.
- target이 unhealthy면 `/var/log/cloud-init-output.log`부터 본다.
