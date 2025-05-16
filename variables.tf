variable "project_name" {
  description = "프로젝트 이름"
  type        = string
  default     = "company-infra"
}

variable "environment" {
  description = "환경 (dev, staging, prod 등)"
  type        = string
  default     = ""
}

variable "aws_region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-northeast-2"
}

# 키 페어 관련 변수
variable "create_key_pairs" {
  description = "키 페어 생성 여부"
  type        = bool
  default     = false
}

variable "key_pairs" {
  description = "생성할 키 페어 목록"
  type = list(object({
    name       = string
    public_key = string
  }))
  default = []
}

variable "vpc_cidr" {
  description = "VPC CIDR 블록"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "사용할 가용 영역 목록"
  type        = list(string)
  default     = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c", "ap-northeast-2d"]
}

variable "public_subnet_cidrs" {
  description = "퍼블릭 서브넷 CIDR 블록 목록"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24"]
}

variable "private_subnet_cidrs" {
  description = "프라이빗 서브넷 CIDR 블록 목록"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24", "10.0.104.0/24"]
}

# EKS 관련 변수
variable "create_eks" {
  description = "EKS 클러스터 생성 여부"
  type        = bool
  default     = false
}

variable "kubernetes_version" {
  description = "사용할 Kubernetes 버전"
  type        = string
  default     = "1.31"
}

variable "eks_node_instance_type" {
  description = "EKS 노드 인스턴스 타입"
  type        = string
  default     = "t3.medium"
}

variable "eks_node_disk_size" {
  description = "EKS 노드 디스크 크기(GB)"
  type        = number
  default     = 20
}

variable "eks_node_desired_size" {
  description = "EKS 노드 그룹의 원하는 노드 수"
  type        = number
  default     = 3
}

variable "eks_node_min_size" {
  description = "EKS 노드 그룹의 최소 노드 수"
  type        = number
  default     = 3
}

variable "eks_node_max_size" {
  description = "EKS 노드 그룹의 최대 노드 수"
  type        = number
  default     = 5
}

variable "eks_key_name" {
  description = "EKS 워커 노드에 사용할 키페어 이름"
  type        = string
  default     = ""
}

# SQS 관련 변수
variable "create_sqs" {
  description = "SQS 큐 생성 여부"
  type        = bool
  default     = false
}

variable "sqs_queues" {
  description = "생성할 SQS 큐 목록"
  type = list(object({
    name                       = string
    fifo_queue                 = bool
    content_based_deduplication = bool
    delay_seconds              = number
    max_message_size           = number
    message_retention_seconds  = number
    receive_wait_time_seconds  = number
    visibility_timeout_seconds = number
    create_queue_policy        = bool
    dead_letter_queue_arn      = string
    max_receive_count          = number
  }))
  default = []
}

# Bastion 서버 관련 변수
variable "create_bastion" {
  description = "Bastion 서버 생성 여부"
  type        = bool
  default     = false
}

variable "bastion_instance_type" {
  description = "Bastion 서버 인스턴스 타입"
  type        = string
  default     = "t3.micro"
}

variable "bastion_volume_size" {
  description = "Bastion 서버 디스크 크기(GB)"
  type        = number
  default     = 8
}

variable "bastion_create_eip" {
  description = "Bastion 서버에 Elastic IP 할당 여부"
  type        = bool
  default     = true
}

variable "bastion_key_name" {
  description = "Bastion 서버에 사용할 기존 키 페어 이름"
  type        = string
  default     = ""
}

variable "bastion_allowed_ssh_cidr_blocks" {
  description = "Bastion 서버 SSH 접속을 허용할 CIDR 블록 목록"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# RDS 관련 변수
variable "create_rds" {
  description = "RDS 인스턴스 생성 여부"
  type        = bool
  default     = false
}

variable "rds_instances" {
  description = "생성할 RDS 인스턴스 목록"
  type = list(object({
    identifier               = string
    engine                   = string
    engine_version           = string
    instance_class           = string
    allocated_storage        = number
    max_allocated_storage    = number
    storage_type             = string
    storage_encrypted        = bool
    db_name                  = string
    username                 = string
    password                 = string
    port                     = number
    multi_az                 = bool
    publicly_accessible      = bool
    allowed_security_groups  = list(string)
    allowed_cidr_blocks      = list(string)
    create_parameter_group   = bool
    parameter_group_family   = string
    parameters               = list(map(string))
    backup_retention_period  = number
    skip_final_snapshot      = bool
    deletion_protection      = bool
    performance_insights_enabled = bool
    enabled_cloudwatch_logs_exports = list(string)
  }))
  default = []
} 