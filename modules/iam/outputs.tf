output "backend_dev_policy_arn" {
  description = "백엔드 개발자 정책 ARN"
  value       = aws_iam_policy.backend_dev_policy.arn
}

output "backend_dev_policy_name" {
  description = "백엔드 개발자 정책 이름"
  value       = aws_iam_policy.backend_dev_policy.name
}

output "backend_dev_group_name" {
  description = "백엔드 개발자 그룹 이름"
  value       = aws_iam_group.backend_devs.name
}

output "backend_dev_group_arn" {
  description = "백엔드 개발자 그룹 ARN"
  value       = aws_iam_group.backend_devs.arn
} 