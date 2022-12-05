region = "us-east-1"
network_details = {
  availability_zones    = ["us-east-1a", "us-east-1b"]
  cidr_block            = "10.10.0.0/16"
  destination_cidr      = "0.0.0.0/0"
  internet_gateway_name = "Load_balancer_IGW"
  protocol              = "tcp"
  route_table_name      = "Load_balancer_Route_table"
  security_group_name   = "Load_balancer_Security_Group"
  subnet_cidrs          = ["10.10.0.0/24", "10.10.1.0/24"]
  subnet_tags           = ["lb_subnet_1", "lb_subnet_2"]
  vpc_name              = "Load_balancer_Vpc"
}
instances_details = {
  ami_id        = "ami-04bc4b706878f89bf"
  instance_tags = ["lb_instance_1", "lb_instance_2"]
  instance_type = "t2.micro"
  key_pair      = "standard"
}
load_balancer_details = {
  load_balancer_name = "Application_Load_Balancer"
  load_balancer_type = "application"
  target_group_name  = "Load_balancer_Target_Group"
  target_type        = "instance"
}
null_resource_details = {
  connection_type = "ssh"
  listener_name   = "Listener-1"
  listener_type   = "forward"
  protocol        = "HTTP"
  user_name       = "ubuntu"
}
