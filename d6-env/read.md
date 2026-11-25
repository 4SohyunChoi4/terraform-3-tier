D6. dev / prod 환경 분리

**구조**
```
d6-env/
├── modules/        # D5 모듈 복사
└── envs/
    ├── dev/        # 실습 apply
    └── prod/       # plan만 확인
```

**dev 실행**
```powershell
cd d6-env\envs\dev
terraform init
terraform validate
terraform plan
terraform apply
terraform output
terraform destroy
```

**prod 확인 (apply 안 함)**
```powershell
cd d6-env\envs\prod
terraform init
terraform plan
```

**S3 state 확인**
```powershell
aws s3 ls s3://sohyun-tf-state-1234/d6-env/ --recursive
```

- [x]  `modules/`를 D5에서 복사해서 dev / prod가 같은 모듈 사용
- [x]  모듈에 `db_instance_class`, `backup_retention_period`, `multi_az` 변수 추가
- [x]  `envs/dev`, `envs/prod`에 `main.tf`, `variables.tf`, `outputs.tf`, `terraform.tfvars` 작성
- [x]  환경별 backend key 분리 (`d6-env/dev/...`, `d6-env/prod/...`)
- [x]  `default_tags`로 `Environment`, `Project` 태그 자동 부여 확인
- [x]  dev apply 후 ALB 응답 확인
- [x]  dev destroy 후 콘솔 잔여 리소스 확인
- [x]  prod는 `plan`만 실행해서 dev와 차이 확인

**dev / prod 차이**

| 항목 | dev | prod |
|---|---|---|
| VPC CIDR | 10.10.0.0/16 | 10.20.0.0/16 |
| 인스턴스 타입 | t3.micro | t3.small |
| ASG 개수 | 1 | 2 |
| DB 사양 | db.t3.micro | db.t3.small |
| 백업 보관 | 0일 | 7일 |
| Multi-AZ | false | true |

**키포인트**
- 같은 모듈을 환경 폴더에서 호출하고, 환경별 차이는 `terraform.tfvars`로만 준다.
- state는 환경마다 key를 나눠서 dev와 prod가 서로 영향을 주지 않게 한다.
- `default_tags`에 환경 값을 넣으면 리소스마다 태그를 반복해서 쓰지 않아도 된다.
- `*.tfvars`는 값만 들어 있어서 비밀번호가 없으면 git에 올려도 되지만, 팀 규칙에 따라 `.gitignore`로 관리할 수 있다.
- 실습 비용 때문에 prod는 `plan`까지만 하고, dev는 확인 후 바로 destroy한다.