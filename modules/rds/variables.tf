variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "environment" {
  description = "환경 (dev, staging, prod 등)"
  type        = string
  default     = "dev"
}

variable "identifier" {
  description = "RDS 인스턴스 식별자"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "RDS가 위치할 서브넷 ID 목록"
  type        = list(string)
}

variable "allowed_security_group_ids" {
  description = "RDS 접근을 허용할 보안 그룹 ID 목록"
  type        = list(string)
  default     = []
}

variable "allowed_cidr_blocks" {
  description = "RDS 접근을 허용할 CIDR 블록 목록"
  type        = list(string)
  default     = []
}

variable "engine" {
  description = "데이터베이스 엔진 (mysql, postgres, etc.)"
  type        = string
}

variable "engine_version" {
  description = "데이터베이스 엔진 버전"
  type        = string
}

variable "instance_class" {
  description = "RDS 인스턴스 클래스"
  type        = string
}

variable "allocated_storage" {
  description = "할당된 스토리지 크기(GB)"
  type        = number
}

variable "max_allocated_storage" {
  description = "자동 확장 가능한 최대 스토리지 크기(GB), 0=자동 확장 비활성화"
  type        = number
  default     = 0
}

variable "storage_type" {
  description = "스토리지 유형 (gp2, gp3, io1 등)"
  type        = string
  default     = "gp3"
}

variable "storage_encrypted" {
  description = "스토리지 암호화 여부"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "스토리지 암호화를 위한 기존 KMS 키 ID"
  type        = string
  default     = ""
}

variable "db_name" {
  description = "초기 데이터베이스 이름"
  type        = string
}

variable "username" {
  description = "마스터 사용자 이름"
  type        = string
}

variable "password" {
  description = "마스터 사용자 비밀번호"
  type        = string
  sensitive   = true
}

variable "port" {
  description = "데이터베이스 포트"
  type        = number
  default     = 5432
}

variable "create_parameter_group" {
  description = "파라미터 그룹 생성 여부"
  type        = bool
  default     = false
}

variable "parameter_group_family" {
  description = "파라미터 그룹 패밀리 (mysql8.0, postgres13 등)"
  type        = string
  default     = ""
}

variable "parameter_group_name" {
  description = "기존 파라미터 그룹 이름 (create_parameter_group이 false인 경우)"
  type        = string
  default     = ""
}

variable "parameters" {
  description = "데이터베이스 파라미터 목록"
  type        = list(map(string))
  default     = []
}

variable "multi_az" {
  description = "다중 가용 영역 배포 여부"
  type        = bool
  default     = false
}

variable "publicly_accessible" {
  description = "공개적으로 접근 가능 여부"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "인스턴스 삭제 시 최종 스냅샷 생성 건너뛰기 여부"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "자동 백업 보존 기간(일)"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "자동 백업 수행 시간 (형식: hh:mm-hh:mm)"
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "유지보수 수행 시간 (형식: ddd:hh:mm-ddd:hh:mm)"
  type        = string
  default     = "Mon:00:00-Mon:03:00"
}

variable "apply_immediately" {
  description = "변경사항 즉시 적용 여부"
  type        = bool
  default     = false
}

variable "auto_minor_version_upgrade" {
  description = "마이너 버전 자동 업그레이드 여부"
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "삭제 보호 활성화 여부"
  type        = bool
  default     = false
}

variable "performance_insights_enabled" {
  description = "성능 인사이트 활성화 여부"
  type        = bool
  default     = false
}

variable "performance_insights_retention_period" {
  description = "성능 인사이트 데이터 보존 기간(일)"
  type        = number
  default     = 7 # 7일(무료)
}

variable "performance_insights_kms_key_id" {
  description = "성능 인사이트를 위한 기존 KMS 키 ID"
  type        = string
  default     = ""
}

variable "enabled_cloudwatch_logs_exports" {
  description = "CloudWatch Logs로 내보낼 로그 유형"
  type        = list(string)
  default     = []
}

variable "prevent_destroy" {
  description = "terraform destroy 방지 여부"
  type        = bool
  default     = false
} 