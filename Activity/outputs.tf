output "vpc_id" {
    value = aws_vpc.my_vpc.id
}
output "Pub_Subnet_Id_1" {
    value = aws_subnet.my_subnets[0].id 
}
output "Pub_Subnet_Id_2" {
    value = aws_subnet.my_subnets[1].id 
}
output "Pvt_Subnet_Id_1" {
    value = aws_subnet.my_subnets[2].id 
}
output "Pvt_Subnet_Id_2" {
    value = aws_subnet.my_subnets[3].id 
}
output "igw_id" {
    value = aws_internet_gateway.my_igw.id
}
output "elastic_ip_id" {
    value = aws_eip.my_eip.allocation_id
}
output "nat_gateway_id" {
    value = aws_nat_gateway.my_nat.id
}
output "pub_rt_id" {
    value = aws_route_table.my_rts[0].id
}
output "pvt_rt_id" {
    value = aws_route_table.my_rts[1].id
}
output "igw_assc_id_1" {
    value = aws_route_table_association.igw_assc_1.id
}
output "igw_assc_id_2" {
    value = aws_route_table_association.igw_assc_2.id
}
output "nat_gateway_assc_id_1" {
    value = aws_route_table_association.nat_assc_1.id
}
output "nat_gateway_assc_id_2" {
    value = aws_route_table_association.nat_assc_2.id
}
output "pub_sg_id" {
    value = aws_security_group.my_sg_pub.id
}
output "pvt_sg_id" {
    value = aws_security_group.my_sg_pvt.id
}
output "pub_instance_id" {
    value = aws_instance.pub_instance.id
}
output "pvt_instance_id" {
    value = aws_instance.pvt_instance.id
}
output "target_group_arn" {
    value = aws_lb_target_group.tg.arn
}
output "target_group_attachament_1_id" {
    value = aws_lb_target_group_attachment.TG_Attach1.id
}
output "target_group_attachament_2_id" {
    value = aws_lb_target_group_attachment.TG_Attach2.id
}
output "load_balancer_dns" {
    value = aws_lb.app_lb.dns_name
}
output "listener_id" {
    value = aws_lb_listener.alb_listener.id
}