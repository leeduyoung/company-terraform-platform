output "vpc_id" {
  description = "생성된 VPC의 ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "생성된 퍼블릭 서브넷 ID 목록"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "생성된 프라이빗 서브넷 ID 목록"
  value       = aws_subnet.private[*].id
}

output "nat_gateway_ip" {
  description = "NAT 게이트웨이의 퍼블릭 IP"
  value       = aws_eip.nat.public_ip
}

output "nat_gateway_id" {
  description = "NAT 게이트웨이 ID"
  value       = aws_nat_gateway.main.id
}

output "public_route_table_id" {
  description = "퍼블릭 라우팅 테이블 ID"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "프라이빗 라우팅 테이블 ID"
  value       = aws_route_table.private.id
} 