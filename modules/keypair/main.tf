resource "aws_key_pair" "this" {
  count = var.create ? 1 : 0

  key_name   = var.key_name
  public_key = var.public_key

  tags = {
    Name        = var.key_name
    Environment = var.environment
    Project     = var.project_name
  }
} 