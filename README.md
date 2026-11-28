# Terraform 3-tier architecture

# 주제

**“Terraform으로 만드는 3-tier 웹 아키텍처 (+ 고객 전달용 문서)”**

- 네트워크: VPC, public/private 서브넷 2개 AZ, NAT, 보안그룹
- 컴퓨트: ALB + ASG(EC2) 또는 ECS Fargate 중 하나 (Spring Boot 샘플 앱 또는 nginx)
- DB: RDS PostgreSQL (private subnet), 비밀번호는 Secrets Manager
- 운영: 원격 state(S3 + 락), 환경 분리(dev/prod), 태그 정책, CloudWatch 알람
- CI: GitHub Actions에서 `fmt` / `validate` / `tflint` / `checkov` / PR에 `plan` 코멘트, AWS 인증은 OIDC

# Terraform 개념

- provider : Providers are Terraform plugins that define resources and data sources for practitioners to use. Providers are wrapped by a provider server for interacting with Terraform.
- resource :

Resources are an abstraction that allow Terraform to manage infrastructure objects, such as a compute instance, an access policy, or disk. Terraform assumes that every resource:

- operates as a pure key/value store, with values getting returned exactly as they were written.
- needs only one API call to update or return its state.
- can be created, read, updated, and deleted.
- state : 내가 AWS에 만든 리소스가 무엇인지, 각각 어떤 Id와 속성을 가졌는지를 기록해둔 장부
    - **state는 `terraform.tfstate` 파일**이고, 지금은 S3 버킷에 저장돼 있어요. 로컬에는 없어요.

  코드에는 “VPC를 만들어라”라고만 적혀 있고, 실제 AWS의 VPC ID(`vpc-0abc...`)는 적혀 있지 않아요. Terraform은 apply 후에 AWS가 준 ID를 state에 저장해둬요. 그래서 다음 `plan`에서 이렇게 판단할 수 있어요.

    - 코드에 있고 state에도 있음 → 이미 있으니까 **변경 여부만 확인**
    - 코드에 있고 state에 없음 → **새로 생성**
    - state에 있고 코드에서 지움 → **삭제**

  즉 **코드(원하는 상태) vs state(지금 상태)를 비교해서 차이만 바꾸는 기준점**이 state예요.


# Terraform configuration

- `network.tf`

```bash
data "aws_availability_zones" "available" {
  state= "available"
  }
```

`"aws_availability_zones"` : AWS에서 현재 리전의 AZ 목록을 읽어오는 조회 코드이다. 새로 만드는 리소스가 아니라 읽기 전용이다.

- 리전이 바뀌어도 코드를 고치지 않기 위해서. 즉, 같은 코드를 여러 환경에서 재사용하기 위해.
- `data.aws_availability_zones.available.names`에 `["ap-northeast-2a", "ap-northeast-2b", ...]` 같은 리스트가 들어오게 된다.
- main.tf : 리소스와 데이터 소스를 포함한다.
- modules/aws-ec2-instance : AWS에 EC2 인스턴스를 프로비저닝 하기 위한 Terraform module 디렉토리이다.
- terraform.tf : Terraform 블록이 정의된다. 여기엔 provider, remote backend, Terraform 버전이 설정된다.
- `terraform.tfstate` : AWS의 리소스 정보가 기록된다.
- variables.tf : 변수 선언

# 주요 명령어

### `terraform init`

내 설정을 apply하기 위해 workspace를 준비한다.

init을 하게 되면, Terraform은 backend를 설정하고, 참조된 provider와 module을 설치하고, version lock 파일을 새로 생성한다. 또한 workspace의 backend를 변경하고 워크스페이스의 provider와 module을 업그레이드 하기 위해서도 사용할 수 있다.

1. 백엔드를 initialize한다. 이때 terraform 블록에 cloud, backend 블록이 없으면 로컬 백엔드를 디폴트로 한다.
2. configuration에 맞는 모듈을 설치한다.
    1. module “ec2-instance” 블록 : 로컬의 modules/ec2-instance 모듈을 사용한다.
    2. module “hello” 블록 : public Terraform Registry에서 다운로드 해 온다.
3. configration에 맞는 provider를 설치한다.
    1. 아직 lock file이 없기 때문에, 테라폼은 terraform.tf에 있는 required_provider 블록에 명시된 aws, random Provider를 다운로드 한다.
    2. workspace를 초기화할 때, 테라폼은 워크스페이스의 Lock file에 명시된 버전의 provider를 다운로드 하려고 한다. lock file이 없으면, required_providers 블록으로 Provider의 버전을 만들고, lock file을 새로 만든다. 둘 다 없으면, 매칭되는 프로바이더를 찾고 최신 버전으로 다운로드 한다.

```bash
terraform init
Initializing the backend...

Initializing modules...

╷
│ Error: Backend configuration changed
│ 
│ A change in the backend configuration has been detected, which may require migrating
│ existing state.
│ 
│ If you wish to attempt automatic migration of the state, run "terraform init
│ -migrate-state".
│ If you wish to store the current configuration with no changes to the state, run
│ "terraform init -reconfigure".
╵

```

`terraform init -reconfigure`  : 기존 state를 옮기지 않고 현재 backend 설정으로 다시 연결만 한다.

`terraform init -migrate-state` : 현재 디렉토리에서 apply한 적 있다는 의미. 이 state를 s3로 옮겨야 한다.



## `terraform plan`

allows you to preview the changes Terraform will make before you apply them.


## `terraform apply`

makes the changes defined by your plan to create, update, or destroy resources.