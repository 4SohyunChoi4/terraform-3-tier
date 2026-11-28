# D8. GitHub Actions CI (fmt / validate / tflint / checkov + PR plan 댓글)

**파일 위치**
```
.github/workflows/terraform.yml   # 레포 루트 (GitHub가 여기서만 읽음)
d8-ci/README.md                   # 설명 (이 파일)
```

**AWS 인증 (OIDC, Access Key 없음)**
- IAM → Identity providers → `token.actions.githubusercontent.com` (audience `sts.amazonaws.com`)
- IAM → Roles → `tf-lab-github-plan` (조건: 본인 레포만 허용)
- 권한: `ReadOnlyAccess` + state 버킷 접근

**동작 순서**
1. `checks` 잡: `terraform fmt -check`, `validate`(dev/prod), `tflint`, `checkov`
2. `plan` 잡: `checks` 통과 후 `envs/dev`에서 `plan`, 결과를 PR 댓글로 게시

**실행 확인**
- 브랜치 생성 → commit → push → PR 생성
- PR의 Checks 탭에서 `checks`, `plan` 초록불 확인
- PR 댓글에 `terraform plan (dev)` 출력 확인

- [ ]  OIDC 공급자 생성
- [ ]  `tf-lab-github-plan` 역할 생성 (조건과 권한 설정)
- [ ]  `.github/workflows/terraform.yml` 커밋
- [ ]  `checks` 통과 (fmt, validate, tflint)
- [ ]  `checkov` 결과 확인 (`soft_fail: true`라 경고만 나옴)
- [ ]  PR에 plan 댓글 자동 게시
- [ ]  `*.tfvars`가 Git에 올라가도록 `.gitignore` 정리

**키포인트**
- CI에 장기 Access Key를 넣지 않는다. GitHub가 발급한 단기 토큰으로 역할을 맡는다(OIDC).
- 역할의 신뢰 조건(`sub`)으로 **어떤 레포/브랜치가 AWS에 접근할 수 있는지** 제한한다.
- `fmt`, `validate`는 빠른 문법 검사, `tflint`는 실수 검사, `checkov`는 보안 설정 검사다.
- plan은 AWS 리소스를 바꾸지 않는다. 그래서 PR 단계에서 자동으로 돌려도 된다. apply는 사람이 직접 한다.
