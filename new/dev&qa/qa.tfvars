region = "us-west-2"
vpc_details = {
  cidr_block = "172.168.0.0/16"
  vpc_tag = "for qa"
  destination_cidr = "0.0.0.0/0"
}
subnet_details = {
  azs = ["us-west-2a", "us-west-2b"]
  subnet_cidrs = [ "172.168.0.0/24", "172.168.1.0/24" ]
  subnet_tags = [ "subnet-1", "subnet-2" ]
}
rt_details = {
  route_table_tags = [ "rt-1", "rt-2" ]
}
instance_details = {
  ami_id = "ami-0c09c7eb16d3e8e70"
  instance_type = "t2.micro"
  key_pair = "standard"
  qa_instance_tags = [ "qa-1", "qa-2" ]
}