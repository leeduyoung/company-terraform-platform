variable "create" {
  description = "키 페어 생성 여부"
  type        = bool
  default     = true
}

variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "environment" {
  description = "환경 (dev, staging, prod 등)"
  type        = string
  default     = ""
}

variable "key_name" {
  description = "생성할 키 페어 이름"
  type        = string
}

variable "public_key" {
  description = "키 페어에 사용할 SSH 공개키"
  type        = string
  default     = ""
} 