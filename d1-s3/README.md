D1. Terraform 기본 흐름 + S3 버킷

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform destroy
```

- [x]  Terraform 기본 흐름 (init → plan → apply → destroy) 실행
- [x]  `plan` 출력에서 `+ create`, `~ update`, `- destroy` 의미 확인
- [x]  `terraform.tfstate`에 실제 AWS 리소스 정보가 기록되는 것 확인
- [x]  `apply` 두 번 실행해서 `No changes` 확인 (선언형)
- [x]  `.gitignore`에 `.terraform/`, `*.tfstate*` 추가

**키포인트**
- Terraform은 코드(원하는 상태)와 state(현재 상태)를 비교해서 차이만 바꾼다.
- S3 버킷 이름은 전 세계에서 유일해야 한다.
- 버킷은 비어 있어야 destroy가 된다.
