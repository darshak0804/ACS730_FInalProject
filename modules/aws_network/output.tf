## Output of Network ID will be displayed

output "public_subnets_id" {
  value = aws_subnet.public_subnet[*].id
}

output "private_subnets_id" {
  value = aws_subnet.private_subnet[*].id
}

output "public_subnets_route_table_id" {
  value = aws_route_table.public_subnets_route_table.id
}

output "private_subnets_route_table_id" {
  value = aws_route_table.public_subnets_route_table.id
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_cidr" {
  value = var.vpc_cidr
}
