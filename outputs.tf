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

# Bastion 서버 출력 (조건부)
output "bastion_id" {
  description = "Bastion 서버 인스턴스 ID"
  value       = var.create_bastion ? module.bastion[0].bastion_id : null
}

output "bastion_public_ip" {
  description = "Bastion 서버 퍼블릭 IP (EIP가 없는 경우)"
  value       = var.create_bastion ? module.bastion[0].bastion_public_ip : null
}

output "bastion_elastic_ip" {
  description = "Bastion 서버에 할당된 Elastic IP (있는 경우)"
  value       = var.create_bastion && var.bastion_create_eip ? module.bastion[0].bastion_elastic_ip : null
}

output "bastion_private_ip" {
  description = "Bastion 서버 프라이빗 IP"
  value       = var.create_bastion ? module.bastion[0].bastion_private_ip : null
}

output "bastion_ssh_command" {
  description = "Bastion 서버 SSH 접속 명령어"
  value       = var.create_bastion ? module.bastion[0].ssh_command : null
}

# RDS 출력 (조건부)
output "rds_instance_endpoints" {
  description = "RDS 인스턴스 엔드포인트 목록"
  value       = var.create_rds && length(var.rds_instances) > 0 ? [for db in module.rds : db.db_instance_endpoint] : []
}

output "rds_instance_addresses" {
  description = "RDS 인스턴스 주소 목록"
  value       = var.create_rds && length(var.rds_instances) > 0 ? [for db in module.rds : db.db_instance_address] : []
}

output "rds_instance_ids" {
  description = "RDS 인스턴스 ID 목록"
  value       = var.create_rds && length(var.rds_instances) > 0 ? [for db in module.rds : db.db_instance_id] : []
}

output "rds_instance_names" {
  description = "RDS 데이터베이스 이름 목록"
  value       = var.create_rds && length(var.rds_instances) > 0 ? [for db in module.rds : db.db_instance_name] : []
}

output "rds_jdbc_connection_strings" {
  description = "RDS JDBC 연결 문자열 목록"
  value       = var.create_rds && length(var.rds_instances) > 0 ? [for db in module.rds : db.jdbc_connection_string] : []
}

output "rds_connection_commands" {
  description = "RDS 연결 명령어 목록"
  value       = var.create_rds && length(var.rds_instances) > 0 ? [for db in module.rds : db.connection_command] : []
} 