# ec2_details = {
#   ami_id = "ami-0778521d914d23bc1"
#   instance_type = "t2.micro"
#   key_pair = "kaaju"
#   security_group_id = "sg-0800709dc00230924"
#   subnet_id = "subnet-0e258a04d9e49f4b9"
#   trigger = "1.1"
#   instance_tags = [ "ansible-master", "ansible-node-1"]
# }

provisioner_variables = {
  connection_type = "ssh"
  host_ip = "54.157.145.185"
  null_trigger = "1.2"
  user_name = "ansible"
  user_password = "tarun"
}