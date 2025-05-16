# SQS 큐 생성
resource "aws_sqs_queue" "main" {
  # FIFO 큐인 경우 .fifo 접미사 자동 추가
  name                       = var.fifo_queue ? "${var.project_name}-${var.queue_name}.fifo" : "${var.project_name}-${var.queue_name}"
  delay_seconds              = var.delay_seconds
  max_message_size           = var.max_message_size
  message_retention_seconds  = var.message_retention_seconds
  receive_wait_time_seconds  = var.receive_wait_time_seconds
  visibility_timeout_seconds = var.visibility_timeout_seconds
  fifo_queue                 = var.fifo_queue
  content_based_deduplication = var.content_based_deduplication

  # 암호화 설정
  kms_master_key_id                 = var.kms_master_key_id
  kms_data_key_reuse_period_seconds = var.kms_key_reuse_seconds

  # 데드 레터 큐 설정 (옵션)
  redrive_policy = var.dead_letter_queue_arn != "" ? jsonencode({
    deadLetterTargetArn = var.dead_letter_queue_arn
    maxReceiveCount     = var.max_receive_count
  }) : null

  tags = {
    Name        = "${var.project_name}-${var.queue_name}"
    Environment = var.environment
  }
}

# 큐 정책 (옵션)
resource "aws_sqs_queue_policy" "main" {
  count     = var.create_queue_policy ? 1 : 0
  queue_url = aws_sqs_queue.main.url

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "${var.project_name}-${var.queue_name}-policy"
    Statement = concat([
      {
        Sid       = "AllowSameAccountSendReceive"
        Effect    = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action    = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource  = aws_sqs_queue.main.arn
      }
    ], var.additional_policy_statements)
  })
}

# 현재 계정 ID 가져오기
data "aws_caller_identity" "current" {} 