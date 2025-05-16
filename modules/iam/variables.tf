variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "policy_name_prefix" {
  description = "IAM 정책 이름 접두사"
  type        = string
  default     = ""
}

variable "group_name_prefix" {
  description = "IAM 그룹 이름 접두사"
  type        = string
  default     = ""
} 