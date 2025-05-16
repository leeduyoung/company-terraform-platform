# Kaye 인프라 프로젝트

테라폼을 사용하여 AWS 인프라를 관리하는 프로젝트입니다.

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

## 모듈 구조

프로젝트는 다음과 같은 모듈로 구성되어 있습니다:

- **네트워크 모듈** (`modules/network`): VPC, 서브넷, 게이트웨이, 라우팅 테이블 관리
- **IAM 모듈** (`modules/iam`): IAM 정책, 그룹, 사용자 관리
- **EKS 모듈** (`modules/eks`): Kubernetes 클러스터 및 노드 그룹 관리
- **SQS 모듈** (`modules/sqs`): 메시지 큐 서비스 관리

## 환경별 설정

이 프로젝트는 다음과 같은 환경을 지원합니다:

- **개발 환경** (`dev.tfvars`): 
  - 2개의 가용 영역 사용
  - EKS는 t3.medium 인스턴스 3개 사용
  - SQS는 backend-tasks(표준) 및 notification-events(FIFO) 큐 제공
- **테스트 환경** (`test.tfvars`): 2개의 가용 영역 사용
- **프로덕션 환경** (`prod.tfvars`): 
  - 4개의 가용 영역 사용 
  - EKS는 t3.large 인스턴스 3개 사용 (최대 10개까지 확장 가능)
  - SQS는 backend-tasks(표준), notification-events(FIFO), audit-logs(표준) 큐 제공

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
aws eks update-kubeconfig --name kaye-dev-cluster --region ap-northeast-2
```

## SQS 큐 사용 방법

AWS SQS 큐는 다음과 같이 사용할 수 있습니다:

### 메시지 전송

```bash
# 표준 큐에 메시지 전송
aws sqs send-message \
  --queue-url https://sqs.ap-northeast-2.amazonaws.com/123456789012/kaye-dev-backend-tasks \
  --message-body '{"task": "process_data", "data": {"id": 123}}' \
  --region ap-northeast-2

# FIFO 큐에 메시지 전송 (MessageGroupId 필수)
aws sqs send-message \
  --queue-url https://sqs.ap-northeast-2.amazonaws.com/123456789012/kaye-dev-notification-events.fifo \
  --message-body '{"event": "user_signup", "data": {"user_id": 456}}' \
  --message-group-id "user_events" \
  --message-deduplication-id "$(date +%s)" \
  --region ap-northeast-2
```

### 메시지 수신

```bash
# 큐에서 메시지 수신
aws sqs receive-message \
  --queue-url https://sqs.ap-northeast-2.amazonaws.com/123456789012/kaye-dev-backend-tasks \
  --max-number-of-messages 10 \
  --visibility-timeout 30 \
  --wait-time-seconds 20 \
  --region ap-northeast-2
```

### 메시지 삭제

```bash
# 메시지 수신 후 삭제
aws sqs delete-message \
  --queue-url https://sqs.ap-northeast-2.amazonaws.com/123456789012/kaye-dev-backend-tasks \
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
- `sqs_queues`: SQS 큐 설정
