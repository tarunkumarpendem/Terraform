region = "us-east-1"
vpc_details = {
  cidr_block = "10.10.0.0/16"
  vpc_tag = "for dev & qa"
  destination_cidr = "0.0.0.0/0"
}
subnet_details = {
  azs = ["us-east-1a", "us-east-1b"]
  subnet_cidrs = [ "10.10.0.0/24", "10.10.1.0/24" ]
  subnet_tags = [ "subnet-1", "subnet-2" ]
}
rt_details = {
  route_table_tags = [ "rt-1", "rt-2" ]
}