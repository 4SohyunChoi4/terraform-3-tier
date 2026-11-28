D2. VPC 네트워크 (public / private 서브넷, IGW, NAT)

```bash
terraform init
terraform plan
terraform apply
terraform output
terraform destroy   # NAT는 시간당 과금, 실습 후 바로 정리
```

- [x]  `variables.tf`, `outputs.tf` 분리
- [x]  `data "aws_availability_zones"`로 AZ 조회 (리전이 바뀌어도 코드 유지)
- [x]  VPC, public 서브넷 2개, private 서브넷 2개 생성
- [x]  IGW + public 라우트 테이블 (`0.0.0.0/0 → igw`)
- [x]  NAT 1개 + private 라우트 테이블 (`0.0.0.0/0 → nat`)
- [x]  destroy 후 콘솔에서 잔여 리소스(NAT, EIP) 없음 확인

**키포인트**
- private 서브넷은 인터넷에서 직접 들어올 수 없고, 나갈 때만 NAT를 거친다.
- NAT는 public 서브넷에 있어야 IGW로 나갈 수 있다.
- `count`는 인덱스 기반이라 중간 항목을 지우면 다른 서브넷이 재생성될 수 있다. `for_each`는 키 기반이라 안전하다.
