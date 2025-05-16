output "vpc_id" {
  description = "생성된 VPC의 ID"
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "생성된 퍼블릭 서브넷 ID 목록"
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "생성된 프라이빗 서브넷 ID 목록"
  value       = module.network.private_subnet_ids
}

output "nat_gateway_ip" {
  description = "NAT 게이트웨이의 퍼블릭 IP"
  value       = module.network.nat_gateway_ip
}

output "nat_gateway_id" {
  description = "NAT 게이트웨이 ID"
  value       = module.network.nat_gateway_id
}

output "public_route_table_id" {
  description = "퍼블릭 라우팅 테이블 ID"
  value       = module.network.public_route_table_id
}

output "private_route_table_id" {
  description = "프라이빗 라우팅 테이블 ID"
  value       = module.network.private_route_table_id
}

# IAM 출력
output "backend_dev_policy_arn" {
  description = "백엔드 개발자 정책 ARN"
  value       = module.iam.backend_dev_policy_arn
}

output "backend_dev_group_name" {
  description = "백엔드 개발자 그룹 이름"
  value       = module.iam.backend_dev_group_name
}

output "backend_dev_group_arn" {
  description = "백엔드 개발자 그룹 ARN"
  value       = module.iam.backend_dev_group_arn
}

# EKS 출력 (조건부)
output "eks_cluster_id" {
  description = "EKS 클러스터 ID"
  value       = var.create_eks ? module.eks[0].cluster_id : null
}

output "eks_cluster_endpoint" {
  description = "EKS 클러스터 엔드포인트"
  value       = var.create_eks ? module.eks[0].cluster_endpoint : null
}

output "eks_node_group_id" {
  description = "EKS 노드 그룹 ID"
  value       = var.create_eks ? module.eks[0].node_group_id : null
}

output "kubectl_config_command" {
  description = "kubectl 구성을 위한 AWS CLI 명령어"
  value       = var.create_eks ? module.eks[0].kubectl_config_command : null
}

# SQS 출력 (조건부)
output "sqs_queue_urls" {
  description = "생성된 SQS 큐 URL 목록"
  value       = var.create_sqs && length(var.sqs_queues) > 0 ? [for q in module.sqs : q.queue_url] : []
}

output "sqs_queue_arns" {
  description = "생성된 SQS 큐 ARN 목록"
  value       = var.create_sqs && length(var.sqs_queues) > 0 ? [for q in module.sqs : q.queue_arn] : []
}

output "sqs_queue_names" {
  description = "생성된 SQS 큐 이름 목록"
  value       = var.create_sqs && length(var.sqs_queues) > 0 ? [for q in module.sqs : q.queue_name] : []
} 