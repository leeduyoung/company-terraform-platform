variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "environment" {
  description = "환경 (dev, staging, prod 등)"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_id" {
  description = "서브넷 ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 인스턴스 타입"
  type        = string
  default     = "t3.micro"
}

variable "volume_size" {
  description = "루트 볼륨 크기(GB)"
  type        = number
  default     = 8
}

variable "ami_id" {
  description = "사용할 AMI ID (비워두면 최신 Amazon Linux 2 사용)"
  type        = string
  default     = ""
}

variable "user_data" {
  description = "EC2 인스턴스 시작 시 실행할 사용자 데이터 스크립트"
  type        = string
  default     = ""
}

variable "key_name" {
  description = "사용할, 미리 생성된 키 페어 이름"
  type        = string
}

variable "create_eip" {
  description = "Elastic IP 생성 여부"
  type        = bool
  default     = true
}

variable "allowed_ssh_cidr_blocks" {
  description = "SSH 접속을 허용할 CIDR 블록"
  type        = list(string)
  default     = ["0.0.0.0/0"]
} 