output "vpc_id" {
  value = aws_vpc.module_vpc.id
}

output "PrivateDbSubnet" {
  value = aws_subnet.PrivateDbSubnet.id
}

output "PrivateAppSubnet" {
  value = aws_subnet.PrivateAppSubnet.id
}
output "PrivateAppSubnet2" {
  value = aws_subnet.PrivateAppSubnet2.id
}

output "subnet_id" {
  value = aws_subnet.module_subnet[*].id
}
