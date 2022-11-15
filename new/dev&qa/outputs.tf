# vpc Id
output "Vpc_Id" {
    value = aws_vpc.vpc.id 
}

# subnet Id's
output "subnet1_Id" {
    value = aws_subnet.subnets[0].id 
}
output "subnet2_Id" {
    value = aws_subnet.subnets[1].id 
}

# Internet Gateway Id
output "igw_Id" {
    value = aws_internet_gateway.igw.id
}

# Route Table Id's
output "rt-1_Id" {
    value = aws_route_table.route_table[0].id 
}
output "rt-2_Id" {
    value = aws_route_table.route_table[1].id 
}