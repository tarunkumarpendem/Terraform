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

# Elastic Ip
output "Elastic_ip_id" {
    value = aws_eip.elastic_ip.allocation_id
  
}

# Nat Gateway Id
output "Nat_Gateway_Id" {
    value = aws_nat_gateway.nat_gateway.id 
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

# Target group Arn
output "tg_arn" {
    value = aws_lb_target_group.tg.arn
}

# TargetGroupAttachment1_Id
output "TG_Attach_Id1" {
  value = aws_lb_target_group_attachment.TG_Attach1.id
}
# TargetGroupAttachment2_Id
output "TG_Attach_Id2" {
  value = aws_lb_target_group_attachment.TG_Attach2.id
}
# Application_Load_Balancer_Id
output "ALB_arn" {
  value = aws_lb.app_lb.id 
}

# Application load balancer DNS Name    
output "ALB_DNS" {
  value = aws_lb.app_lb.dns_name
}                            

# Listener_Id
output "Listener_arn" {
  value = aws_lb_listener.alb_listener.id  
}