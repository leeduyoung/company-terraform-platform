# AWS 기반의 Kubernetes 인프라 환경

테라폼을 사용하여 쿠버네티스 인프라를 관리하는 프로젝트입니다.

## 인프라 구성

- **VPC**: CIDR 10.0.0.0/16
- **서브넷 구성** (환경별 차이가 있음):
  - **퍼블릭 서브넷**: 10.0.1.0/24, 10.0.2.0/24, 10.0.3.0/24, 10.0.4.0/24
  - **프라이빗 서브넷**: 10.0.101.0/24, 10.0.102.0/24, 10.0.103.0/24, 10.0.104.0/24
- **라우팅 테이블**: 퍼블릭 RT, 프라이빗 RT로 구분 운영
- **NAT Gateway**: 비용 고려하여 1개만 사용 (첫 번째 퍼블릭 서브넷에 위치)
- **IAM 권한**: 백엔드 개발자를 위한 권한 관리
- **EKS 클러스터**: EC2 3개 노드 기반 쿠버네티스 클러스터
- **SQS 큐**: 메시지 큐 서비스 (FIFO 및 표준 큐 지원)
- **Bastion 서버**: 프라이빗 리소스 접근용 EC2 인스턴스 (SSH 터널링 지원)
- **RDS 인스턴스**: 관계형 데이터베이스 서비스 (PostgreSQL, MySQL 지원)
- **SSH 키 페어**: 환경별로 구분된 EC2 인스턴스 접속용 키 페어

## 모듈 구조

프로젝트는 다음과 같은 모듈로 구성되어 있습니다:

- **네트워크 모듈** (`modules/network`): VPC, 서브넷, 게이트웨이, 라우팅 테이블 관리
- **IAM 모듈** (`modules/iam`): IAM 정책, 그룹, 사용자 관리
- **EKS 모듈** (`modules/eks`): Kubernetes 클러스터 및 노드 그룹 관리
- **SQS 모듈** (`modules/sqs`): 메시지 큐 서비스 관리
- **Bastion 모듈** (`modules/bastion`): 프라이빗 리소스 접근용 Bastion 서버 관리
- **RDS 모듈** (`modules/rds`): 관계형 데이터베이스 서비스 관리
- **키 페어 모듈** (`modules/keypair`): SSH 접속용 키 페어 관리

## 환경별 설정

이 프로젝트는 다음과 같은 환경을 지원합니다:

- **개발 환경** (`dev.tfvars`): 
  - 2개의 가용 영역 사용
  - EKS는 t3.medium 인스턴스 3개 사용
  - SQS는 backend-tasks(표준) 및 notification-events(FIFO) 큐 제공
  - Bastion 서버는 t3.micro 인스턴스 사용 (누구나 SSH 접속 가능)
  - RDS는 PostgreSQL 단일 인스턴스 사용 (t3.medium, 단일 AZ)
- **테스트 환경** (`test.tfvars`): 2개의 가용 영역 사용
- **프로덕션 환경** (`prod.tfvars`): 
  - 4개의 가용 영역 사용 
  - EKS는 t3.large 인스턴스 3개 사용 (최대 10개까지 확장 가능)
  - SQS는 backend-tasks(표준), notification-events(FIFO), audit-logs(표준) 큐 제공
  - Bastion 서버는 t3.micro 인스턴스 사용 (특정 IP에서만 SSH 접속 가능)
  - RDS는 PostgreSQL 및 MySQL 다중 인스턴스 사용 (r6g.large, 다중 AZ)

## 사용 방법

### 필수 조건

- Terraform v1.2.0 이상
- AWS CLI 구성 완료
- kubectl (EKS 클러스터 관리 시 필요)

### 초기화

```bash
terraform init
```

### 환경별 계획 확인

```bash
# 개발 환경
terraform plan -var-file="dev.tfvars"

# 테스트 환경
terraform plan -var-file="test.tfvars"

# 프로덕션 환경
terraform plan -var-file="prod.tfvars"
```

### 환경별 인프라 배포

```bash
# 개발 환경
terraform apply -var-file="dev.tfvars"

# 테스트 환경
terraform apply -var-file="test.tfvars"

# 프로덕션 환경
terraform apply -var-file="prod.tfvars"
```

### 인프라 삭제

```bash
# 개발 환경
terraform destroy -var-file="dev.tfvars"

# 테스트 환경
terraform destroy -var-file="test.tfvars"

# 프로덕션 환경
terraform destroy -var-file="prod.tfvars"
```

### kubectl 구성 (EKS 클러스터 배포 후)

배포가 완료되면 출력에 표시되는 명령어를 사용하여 kubectl을 구성할 수 있습니다:

```bash
# 예시
aws eks update-kubeconfig --name company-dev-cluster --region ap-northeast-2
```

## Bastion 서버 사용 방법

Bastion 서버는 다음과 같은 용도로 사용할 수 있습니다:

### SSH 접속

```bash
# 인프라 배포 후 출력된 명령어 사용
ssh -i ~/.ssh/your-private-key.pem ec2-user@<bastion-public-ip>
```

### 프라이빗 리소스 접근을 위한 SSH 터널링

```bash
# EKS 클러스터 API 서버 접근 (로컬 포트 8443을 클러스터 API 서버 포트 443으로 포워딩)
ssh -i ~/.ssh/your-private-key.pem -L 8443:<eks-cluster-endpoint>:443 ec2-user@<bastion-public-ip>

# 프라이빗 서브넷 내 데이터베이스 접근
ssh -i ~/.ssh/your-private-key.pem -L 5432:<db-private-ip>:5432 ec2-user@<bastion-public-ip>
```

### RDS 접근 예시

Bastion 서버를 통해 RDS 데이터베이스에 접근하는 방법:

1. SSH 터널 설정:
```bash
# PostgreSQL 접근 터널링
ssh -i ~/.ssh/your-private-key.pem -L 5432:<rds-endpoint>:5432 ec2-user@<bastion-public-ip>

# MySQL 접근 터널링
ssh -i ~/.ssh/your-private-key.pem -L 3306:<rds-endpoint>:3306 ec2-user@<bastion-public-ip>
```

2. 로컬에서 데이터베이스 클라이언트로 연결:
```bash
# PostgreSQL 접속
psql -h localhost -p 5432 -U company_admin -d companydb

# MySQL 접속
mysql -h localhost -P 3306 -u company_admin -p companymysqldb
```

## RDS 관리 방법

### RDS 인스턴스 정보 확인

```bash
# 인스턴스 엔드포인트 목록 확인
terraform output rds_instance_endpoints

# 연결 명령어 확인
terraform output rds_connection_commands
```

### RDS 백업 및 복원

AWS Management Console 또는 AWS CLI를 통해 백업 및 복원을 수행할 수 있습니다:

```bash
# 수동 스냅샷 생성
aws rds create-db-snapshot \
  --db-instance-identifier company-dev-postgres \
  --db-snapshot-identifier manual-backup-20240101

# 스냅샷에서 복원
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier company-dev-postgres-restored \
  --db-snapshot-identifier manual-backup-20240101
```

## SQS 큐 사용 방법

AWS SQS 큐는 다음과 같이 사용할 수 있습니다:

### 메시지 전송

```bash
# 표준 큐에 메시지 전송
aws sqs send-message \
  --queue-url https://sqs.ap-northeast-2.amazonaws.com/123456789012/company-dev-backend-tasks \
  --message-body '{"task": "process_data", "data": {"id": 123}}' \
  --region ap-northeast-2

# FIFO 큐에 메시지 전송 (MessageGroupId 필수)
aws sqs send-message \
  --queue-url https://sqs.ap-northeast-2.amazonaws.com/123456789012/company-dev-notification-events.fifo \
  --message-body '{"event": "user_signup", "data": {"user_id": 456}}' \
  --message-group-id "user_events" \
  --message-deduplication-id "$(date +%s)" \
  --region ap-northeast-2
```

### 메시지 수신

```bash
# 큐에서 메시지 수신
aws sqs receive-message \
  --queue-url https://sqs.ap-northeast-2.amazonaws.com/123456789012/company-dev-backend-tasks \
  --max-number-of-messages 10 \
  --visibility-timeout 30 \
  --wait-time-seconds 20 \
  --region ap-northeast-2
```

### 메시지 삭제

```bash
# 메시지 수신 후 삭제
aws sqs delete-message \
  --queue-url https://sqs.ap-northeast-2.amazonaws.com/123456789012/company-dev-backend-tasks \
  --receipt-handle "수신한 메시지의 receipt-handle 값" \
  --region ap-northeast-2
```

## 주요 파일

- `main.tf`: 메인 인프라 구성 정의
- `variables.tf`: 변수 정의
- `outputs.tf`: 출력 변수 정의

## 커스터마이징

필요에 따라 `variables.tf` 파일에서 다음 값을 변경할 수 있습니다:

- `project_name`: 프로젝트 이름
- `aws_region`: AWS 리전
- `vpc_cidr`: VPC CIDR 블록
- `availability_zones`: 가용 영역 목록
- `public_subnet_cidrs`: 퍼블릭 서브넷 CIDR 블록 목록
- `private_subnet_cidrs`: 프라이빗 서브넷 CIDR 블록 목록
- `key_pairs`: SSH 키 페어 설정 (이름 및 공개키)
- `sqs_queues`: SQS 큐 설정
- `bastion_allowed_ssh_cidr_blocks`: Bastion 서버 SSH 접속 허용 IP 범위
- `rds_instances`: RDS 인스턴스 설정

## 키 페어 관리

SSH 키 페어는 Bastion 서버와 EKS 노드에 접속하기 위해 사용됩니다.

### 키 페어 설정

각 환경에 맞는 키 페어가 자동으로 생성되며, 환경별로 다음과 같이 구성됩니다:

- **개발 환경**: `company-dev-key` (Bastion 서버와 EKS 노드에 동일하게 사용)
- **프로덕션 환경**: `company-prod-key` (Bastion 서버와 EKS 노드에 동일하게 사용)

### 개인 키 보안

Terraform은 자동으로 공개 키를 AWS에 업로드하지만, 개인 키는 사용자가 안전하게 보관해야 합니다.
환경별로 올바른 개인 키를 사용하여 인스턴스에 접속하세요.

```bash
# 개발 환경의 Bastion 서버 접속
ssh -i ~/.ssh/company-dev-key.pem ec2-user@<bastion-public-ip>

# 프로덕션 환경의 Bastion 서버 접속
ssh -i ~/.ssh/company-prod-key.pem ec2-user@<bastion-public-ip>
```

## RDS 고급 기능

RDS 모듈은 다음과 같은 고급 기능을 지원합니다:

### 성능 인사이트

성능 인사이트를 활성화하여 데이터베이스 성능을 모니터링할 수 있습니다:

```bash
# 성능 인사이트 대시보드 확인 (AWS Management Console)
https://console.aws.amazon.com/rds/home?region=ap-northeast-2#performance-insights
```

### 암호화 설정

RDS 인스턴스는 기본적으로 KMS 키를 사용하여 스토리지를 암호화합니다:

```hcl
# storage_encrypted = true 설정 시 자동으로 KMS 키가 생성됩니다
# 또는 기존 KMS 키 사용:
kms_key_id = "arn:aws:kms:ap-northeast-2:123456789012:key/abcd1234-ef56-gh78-ij90-klmn1234pqrs"
```

### 파라미터 그룹 설정

데이터베이스 엔진별 파라미터를 설정할 수 있습니다:

```hcl
# PostgreSQL 파라미터 예시
parameters = [
  {
    name  = "max_connections"
    value = "100"
  },
  {
    name  = "shared_buffers"
    value = "{DBInstanceClassMemory/32768}"
  }
]
```

## 암호화 및 보안

이 프로젝트의 모든 컴포넌트는 보안을 고려하여 설계되었습니다:

### 데이터 암호화

- **저장 데이터(Data at Rest)**: RDS 스토리지 및 EBS 볼륨 암호화
- **전송 중 데이터(Data in Transit)**: TLS/SSL을 통한 통신 암호화
- **SQS 메시지**: KMS 키를 사용한 메시지 암호화

### 보안 그룹 설정

모든 보안 그룹은 최소 권한 원칙을 따라 구성됩니다:

- **Bastion**: 지정된 IP 범위에서만 SSH(22) 접근 허용
- **RDS**: VPC 내부 또는 특정 보안 그룹에서만 데이터베이스 포트 접근 허용
- **EKS**: 컨트롤 플레인과 워커 노드 간 필요한 통신만 허용

### 민감 정보 관리

프로덕션 환경에서는 다음과 같은 방법으로 민감 정보를 관리하는 것을 권장합니다:

- AWS Secrets Manager 사용
- AWS Systems Manager Parameter Store 사용
- HashiCorp Vault 사용

## Makefile 사용 방법

프로젝트 루트에 있는 Makefile을 사용하여 일반적인 작업을 간소화할 수 있습니다:

```bash
# 테라폼 초기화
make init

# 개발 환경 계획 확인
make plan-dev

# 프로덕션 환경 계획 확인
make plan-prod

# 개발 환경 배포
make apply-dev

# 프로덕션 환경 배포
make apply-prod

# 개발 환경 삭제
make destroy-dev

# 테라폼 포맷 검사
make fmt-check

# 테라폼 검증
make validate
```

Makefile에는 이 외에도 다양한 편의 기능이 포함되어 있으니 `make help` 명령을 통해 사용 가능한 모든 명령을 확인하세요.
