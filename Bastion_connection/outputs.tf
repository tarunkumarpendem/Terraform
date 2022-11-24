# Vpc_Id
output "Vpc_Id" {
    value = aws_vpc.bastion_vpc.id
}

# Subnet_Id's
output "public_subnet_Id" {
    value = aws_subnet.bastion_subnets[0].id
}
output "private_subnet_Id" {
    value = aws_subnet.bastion_subnets[1].id
}

# Internet_Gateway_Id
output "Internet_Gateway_Id" {
    value = aws_internet_gateway.igw.id
}

# Route_table_Id's
output "public_rt_Id" {
    value = aws_route_table.bastion_route_tables[0].id 
}
output "private_rt_Id" {
    value = aws_route_table.bastion_route_tables[1].id 
}

# Subnet Association Id's
output "Association_Id_1" {
    value = aws_route_table_association.subnet_association_1.id
}
output "Association_Id_2" {
    value = aws_route_table_association.subnet_association_2.id
}

# Security Group Id
output "Security_Group_Id" {
    value = aws_security_group.bastion_sg.id
}

# Instance Id's
output "public_instance_Id" {
    value = aws_instance.public_instance.id
}
output "private_instance_Id" {
    value = aws_instance.private_instance.id
}