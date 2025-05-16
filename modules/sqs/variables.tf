variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "environment" {
  description = "환경 (dev, test, prod 등)"
  type        = string
  default     = "dev"
}

variable "queue_name" {
  description = "SQS 큐 이름"
  type        = string
}

variable "fifo_queue" {
  description = "FIFO 큐 여부"
  type        = bool
  default     = false
}

variable "content_based_deduplication" {
  description = "콘텐츠 기반 중복 제거 활성화 여부 (FIFO 큐에만 적용)"
  type        = bool
  default     = false
}

variable "delay_seconds" {
  description = "메시지 전송 지연 시간(초)"
  type        = number
  default     = 0
}

variable "max_message_size" {
  description = "최대 메시지 크기(바이트)"
  type        = number
  default     = 262144 # 256KB (AWS SQS 기본값)
}

variable "message_retention_seconds" {
  description = "메시지 보존 기간(초)"
  type        = number
  default     = 345600 # 4일 (AWS SQS 기본값)
}

variable "receive_wait_time_seconds" {
  description = "Long Polling 대기 시간(초)"
  type        = number
  default     = 0
}

variable "visibility_timeout_seconds" {
  description = "메시지 가시성 타임아웃(초)"
  type        = number
  default     = 30
}

variable "kms_master_key_id" {
  description = "SQS 메시지 암호화를 위한 KMS 키 ID"
  type        = string
  default     = ""
}

variable "kms_key_reuse_seconds" {
  description = "KMS 데이터 키 재사용 기간(초)"
  type        = number
  default     = 300
}

variable "create_queue_policy" {
  description = "큐 정책 생성 여부"
  type        = bool
  default     = false
}

variable "dead_letter_queue_arn" {
  description = "데드 레터 큐 ARN"
  type        = string
  default     = ""
}

variable "max_receive_count" {
  description = "메시지가 데드 레터 큐로 이동하기 전 최대 수신 횟수"
  type        = number
  default     = 5
}

variable "additional_policy_statements" {
  description = "추가 IAM 정책 명령문"
  type        = list(any)
  default     = []
} 