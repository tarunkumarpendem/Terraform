region = "us-east-1"
network_details = {
  azs = [ "us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d" ]
  elastic_ip_tag = "my_elastic_ip"
  igw_tag = "my-igw"
  nat_gateway_tag = "nat_gateway"
  rt_destination_cidr = "0.0.0.0/0"
  rt_tags = [ "pub_rt", "pvt_rt" ]
  sg_tags = [ "allow_ssh", "allow_all" ]
  subnet_cidrs = [ "10.10.0.0/24", "10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"  ]
  subnet_tags = [ "pub_subnet_1", "pub_subnet_2", "pvt_subnet_1", "pvt_subnet_2" ]
  vpc_cidr = "10.10.0.0/16"
  vpc_tag = "my_vpc"
}
instance_details = {
  ami_id = "ami-0778521d914d23bc1"
  instance_tags = [ "public_instance", "Private_instance" ]
  instance_type = "t2.micro"
  key_pair = "kaaju"
}
provisioner_variables = {
  connection_type = "ssh"
  null_trigger = "1.1"
  user_name = "ubuntu"
}
load_balancer_details = {
  load_balancer_tag = "app-load-balancer"
  load_balancer_type = "application"
  target_group_tag = "tg"
  port = 80
  protocol = "HTTP"
  listener_tag = "listner-1"
  target_group_name = "TargetGroup"
  target_type = "instance"
  load_balancer_name = "ApplicationLoadBalancer"
  load_balancer_listner_type = "forward"
}