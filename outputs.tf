# Vpc Id
output "Vpc_Id" {
  value = aws_vpc.lb_vpc.id
}

# Subnet's Id
output "Subnet-1_Id" {
  value = aws_subnet.lb_subnets[0].id
}
output "Subnet-2_Id" {
  value = aws_subnet.lb_subnets[1].id
}

# Internet Gateway Id
output "Igw_Id" {
  value = aws_internet_gateway.lb_igw.id
}

# Route Table Id
output "Rt_Id" {
  value = aws_route_table.lb_rt.id
}

# Route Table Association Id's
output "assoc_1_Id" {
  value = aws_route_table_association.subnet_assoc[0].id
}
output "assoc_2_Id" {
  value = aws_route_table_association.subnet_assoc[1].id
}

# Security Group Id
output "Lb_Sg_Id" {
  value = aws_security_group.lb_sg.id
}

# Instance's Id
output "Instance_1_Id" {
  value = aws_instance.lb_instances[0].id
}
output "Instance_2_Id" {
  value = aws_instance.lb_instances[1].id
}

# Target Group ARN
output "tg_arn" {
    value = aws_lb_target_group.lb_tg.arn
}

# Target Group Attachment Id's
output "attachment_Id_1" {
    value = aws_lb_target_group_attachment.tg_attachment[0].id
}
output "attachment_Id_2" {
    value = aws_lb_target_group_attachment.tg_attachment[1].id
}

# Load Balancer DNS name
output "alb_dns_name" {
    value = aws_lb.alb_tf.dns_name
}
