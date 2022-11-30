region = "us-east-1"
network_details = {
  azs = [ "us-east-1a", "us-east-1b" ]
  cidr_block = "10.10.0.0/16"
  internet_gateway_tag = "IGW"
  subnet_cidrs = [ "10.10.0.0/24", "10.10.1.0/24" ]
  subnet_tags = [ "public-subnet", "private-subnet" ]
  vpc_tag = "bastion"
  security_group_tag = "Bastion_Security_Group"
}
route_table_details = {
  destination_cidr = "0.0.0.0/0"
  route_table_tags = [ "public-rt", "private-rt" ]
}
instance_details = {
  ami_id = "ami-0169e00b74f2bb482"
  instance_tags = [ "public-ip", "private-ip" ]
  instance_type = "t2.micro"
  key_pair = "standard"
  null_trigger = "1.1"
}