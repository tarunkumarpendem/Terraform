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

# Rote table association Id's
output "assc_1_Id" {
  value = aws_route_table_association.assc_subnet1.id
}
output "assc_2_Id" {
  value = aws_route_table_association.assc_subnet2.id
}

# Security Group Id
output "security_group_Id" {
  value = aws_security_group.sg.id
}

# dev instance Id
/*output "dev_ec2_Id" {
    value = aws_instance.dev_ec2[0].id  
}*/

# qa instances Id
output "qa_ec2_1_Id" {
  value = aws_instance.qa_ec2[0].id
}
output "qa_ec2_2_Id" {
  value = aws_instance.qa_ec2[1].id
}

# Target group Arn
output "tg_arn" {
  value = aws_lb_target_group.tg[0].arn
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
  value = aws_lb.qa_alb[0].id
}

# Application load balancer DNS Name    
output "ALB_DNS" {
  value = aws_lb.qa_alb[0].dns_name
}

# Listener_Id
output "Listener_arn" {
  value = aws_lb_listener.qa_alb_listener[0].id
}
