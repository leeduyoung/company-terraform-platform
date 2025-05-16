output "key_pair_name" {
  description = "생성된 키 페어 이름"
  value       = var.create ? aws_key_pair.this[0].key_name : var.key_name
}

output "key_pair_id" {
  description = "생성된 키 페어 ID"
  value       = var.create ? aws_key_pair.this[0].id : null
}

output "key_pair_fingerprint" {
  description = "생성된 키 페어의 지문 (fingerprint)"
  value       = var.create ? aws_key_pair.this[0].fingerprint : null
} 