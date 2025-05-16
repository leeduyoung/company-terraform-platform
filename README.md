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

## 모듈 구조

프로젝트는 다음과 같은 모듈로 구성되어 있습니다:

- **네트워크 모듈** (`modules/network`): VPC, 서브넷, 게이트웨이, 라우팅 테이블 관리
- **IAM 모듈** (`modules/iam`): IAM 정책, 그룹, 사용자 관리

## 환경별 설정

이 프로젝트는 다음과 같은 환경을 지원합니다:

- **개발 환경** (`dev.tfvars`): 2개의 가용 영역만 사용
- **테스트 환경** (`test.tfvars`): 2개의 가용 영역만 사용
- **프로덕션 환경** (`prod.tfvars`): 4개의 가용 영역 모두 사용

## 사용 방법

### 필수 조건

- Terraform v1.2.0 이상
- AWS CLI 구성 완료

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
