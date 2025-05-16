output "cluster_id" {
  description = "EKS 클러스터 ID"
  value       = aws_eks_cluster.main.id
}

output "cluster_arn" {
  description = "EKS 클러스터 ARN"
  value       = aws_eks_cluster.main.arn
}

output "cluster_endpoint" {
  description = "EKS 클러스터 엔드포인트"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_security_group_id" {
  description = "EKS 클러스터 보안 그룹 ID"
  value       = aws_security_group.eks_cluster.id
}

output "node_group_id" {
  description = "EKS 노드 그룹 ID"
  value       = aws_eks_node_group.main.id
}

output "node_security_group_id" {
  description = "EKS 노드 보안 그룹 ID"
  value       = aws_security_group.eks_nodes.id
}

output "kubectl_config_command" {
  description = "kubectl 구성을 위한 AWS CLI 명령어"
  value       = "aws eks update-kubeconfig --name ${aws_eks_cluster.main.name} --region ${data.aws_region.current.name}"
}

# 현재 리전 가져오기
data "aws_region" "current" {} 