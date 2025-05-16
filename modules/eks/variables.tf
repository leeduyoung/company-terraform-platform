variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "vpc_id" {
  description = "EKS 클러스터가 생성될 VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "EKS 클러스터 및 노드가 생성될 서브넷 ID 목록"
  type        = list(string)
}

variable "kubernetes_version" {
  description = "사용할 Kubernetes 버전"
  type        = string
  default     = "1.27"
}

variable "node_instance_type" {
  description = "워커 노드의 EC2 인스턴스 타입"
  type        = string
  default     = "t3.medium"
}

variable "node_disk_size" {
  description = "워커 노드의 디스크 크기(GB)"
  type        = number
  default     = 20
}

variable "node_desired_size" {
  description = "노드 그룹의 원하는 노드 수"
  type        = number
  default     = 3 # EC2 3대
}

variable "node_min_size" {
  description = "노드 그룹의 최소 노드 수"
  type        = number
  default     = 3
}

variable "node_max_size" {
  description = "노드 그룹의 최대 노드 수"
  type        = number
  default     = 5
}

variable "key_name" {
  description = "EKS 워커 노드에 사용할 키페어 이름"
  type        = string
  default     = ""
} 