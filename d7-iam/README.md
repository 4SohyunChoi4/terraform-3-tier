# D7. IAM 최소 권한 (인스턴스 역할 + 시크릿 한 개만 읽기)

**1. 검증 (콘솔에서 확인)**
- IAM → Roles → `tf-lab-app-role` → Permissions
  - `AmazonSSMManagedInstanceCore` 연결 확인
  - `read-db-secret` 인라인 정책의 Resource가 시크릿 ARN 하나인지 확인 (`*` 없음)
- IAM → Policy simulator → `tf-lab-app-role`
  - `secretsmanager:GetSecretValue` (DB 시크릿 ARN) → **allowed**
  - `s3:ListAllMyBuckets` → **implicitDeny**

**2. 정리**
```
terraform destroy   # envs/dev에서 실행
```

- [x]  인스턴스 프로파일과 역할 생성 (`tf-lab-app-role`, `tf-lab-app-profile`)
- [x]  Launch Template에 인스턴스 프로파일 연결
- [x]  SSM 관리형 정책 연결
- [x]  시크릿 ARN 한 개만 허용하는 인라인 정책 작성 (`Resource: "*"` 없음)
- [x]  Policy simulator로 허용/차단 확인
- [ ]  Session Manager 접속 확인 (미완료: Fleet Manager에 인스턴스가 등록되지 않음)

**키포인트**
- 인스턴스 권한은 사람 계정이 아니라 **역할**로 준다. 키를 인스턴스에 넣지 않는다.
- 권한은 "필요한 작업 + 필요한 리소스"로 좁힌다. 시크릿 하나만 읽게 하고 나머지는 암묵적으로 막힌다.
- 이미 떠 있는 인스턴스는 역할이 자동으로 붙지 않는다. Launch Template이 바뀌면 인스턴스를 종료해서 ASG가 새로 만들게 한다.
- 순환 참조 주의: 앱 SG → DB SG 규칙은 모듈 밖(`aws_security_group_rule`)에서 만들어야 `compute`와 `database`가 서로 기다리지 않는다.
- Session Manager는 public IP 없이 접속하는 방식이다. 접속이 안 되면 Fleet Manager에서 등록 여부부터 본다.
