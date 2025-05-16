output "queue_id" {
  description = "SQS 큐 ID"
  value       = aws_sqs_queue.main.id
}

output "queue_arn" {
  description = "SQS 큐 ARN"
  value       = aws_sqs_queue.main.arn
}

output "queue_url" {
  description = "SQS 큐 URL"
  value       = aws_sqs_queue.main.url
}

output "queue_name" {
  description = "SQS 큐 이름"
  value       = aws_sqs_queue.main.name
} 