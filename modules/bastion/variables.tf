variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "environment" {
  description = "환경 (dev, staging, prod 등)"
  type        = string
  default     = "dev"
}

variable "vpc_id" {
  description = "Bastion 서버가 배치될 VPC ID"
  type        = string
}

variable "subnet_id" {
  description = "Bastion 서버가 배치될 퍼블릭 서브넷 ID"
  type        = string
}

variable "instance_type" {
  description = "Bastion 서버의 인스턴스 타입"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "Bastion 서버에 사용할 AMI ID (기본값은 최신 Amazon Linux 2)"
  type        = string
  default     = ""
}

variable "volume_size" {
  description = "Bastion 서버의 루트 볼륨 크기(GB)"
  type        = number
  default     = 8
}

variable "key_name" {
  description = "Bastion 서버에 사용할 기존 키 페어 이름 (create_key_pair가 false인 경우 필요)"
  type        = string
  default     = ""
}

variable "create_key_pair" {
  description = "키 페어 생성 여부"
  type        = bool
  default     = false
}

variable "ssh_public_key" {
  description = "Bastion 서버에 사용할 SSH 공개 키 (create_key_pair가 true인 경우 필요)"
  type        = string
  default     = ""
}

variable "allowed_ssh_cidr_blocks" {
  description = "SSH 접속을 허용할 CIDR 블록 목록"
  type        = list(string)
  default     = ["0.0.0.0/0"] # 기본값은 모든 IP 허용 (프로덕션에서는 변경 권장)
}

variable "create_eip" {
  description = "Bastion 서버에 Elastic IP 할당 여부"
  type        = bool
  default     = true
}

variable "user_data" {
  description = "사용자 데이터 스크립트 (기본 설정을 덮어쓰고 싶을 때 사용)"
  type        = string
  default     = ""
} 