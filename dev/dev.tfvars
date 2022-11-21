region = "us-east-1"
availability_zone = "us-east-1a"
vpc_detatils = {
  vpc_cidr = [ "10.10.0.0/16", "172.168.0.0/16" ]
  vpc_tags = [ "dev", "qa" ]
}
vpc_env_count = "1"
subnet_cidr = "10.10.0.0/24"
destination_cidr = "0.0.0.0/0"
trigger_number  = "1.1"
ec2_details = {
  ami_id = "ami-0dca5dba485a4b90c"
  instance_type = "t2.micro"
  keypair = "standard"
}
