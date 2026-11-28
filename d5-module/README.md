D5. 모듈화 + 원격 state

**1. state용 S3 버킷 생성** (Terraform 1.10+ 는 `use_lockfile = true`로 S3 lock 사용)

```bash
aws s3api create-bucket \
  --bucket sohyun-tf-state-1234 \
  --region ap-northeast-2 \
  --create-bucket-configuration LocationConstraint=ap-northeast-2

aws s3api put-bucket-versioning \
  --bucket sohyun-tf-state-1234 \
  --versioning-configuration Status=Enabled
```

**2. backend 연결 후 state 옮기기**

```bash
terraform init -migrate-state
```

**3. 확인 명령**

```bash
terraform validate
terraform plan -no-color | grep -E "^\s+# "   # module.network.*, module.compute.*, module.database.* 로 보여야 함
terraform state list
terraform destroy   # 실습 후 NAT, RDS, ALB 과금 정리
```

- [x]  `modules/network`, `modules/compute`, `modules/database`로 분리
- [x]  루트 `main.tf`에서 모듈 호출, 모듈 간 값은 outputs → variables로 전달
- [x]  원격 state: S3 버킷 + 락 (Terraform 1.10+ 는 `use_lockfile = true`, 그 이하는 DynamoDB 테이블)
- [x]  `terraform init -migrate-state`로 로컬 state 옮기기
- [x]  `validate` 통과, `plan`에서 `module.xxx.*` 주소 확인
- [x]  apply 후 ALB 응답 확인, destroy 후 콘솔 잔여 리소스 확인

**키포인트**
- 자기 모듈이 만든 리소스는 `aws_xxx.yyy.id`로 참조하고, 다른 모듈에서 받은 값은 `var.xxx`로 참조한다.
- 모듈 `variables.tf`는 밖에서 받을 값의 자리만 정의하고, 실제 값은 루트에서 넘긴다.
- 모듈 `outputs.tf`는 다른 모듈에 넘길 값을 내보낸다. 루트 `outputs.tf`는 `module.xxx.yyy`로 참조한다.
- `user_data.sh`는 `file("${path.module}/user_data.sh")`로 읽으므로 compute 모듈 폴더 안에 있어야 한다.
- state는 S3에 두면 팀이 같이 쓰고 lock으로 동시 apply를 막을 수 있다. 로컬 state 삭제 시 리소스를 잃어버리므로 주의한다.
- `init -reconfigure`는 기존 state를 옮기지 않는다. 리소스가 떠 있는 상태에서 쓰면 중복 생성 위험이 있다.
