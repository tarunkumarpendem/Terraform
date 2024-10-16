variable "region" {
  type    = string
  default = "us-east-1"
}

variable "network_details" {
  type = object({
    vpc_cidr            = string
    vpc_tag             = string
    subnet_cidrs        = list(string)
    subnet_tags         = list(string)
    azs                 = list(string)
    igw_tag             = string
    rt_tags             = list(string)
    rt_destination_cidr = string
    sg_tags             = list(string)
  })
  default = {
    vpc_cidr            = "10.10.0.0/16"
    vpc_tag             = "ansible_vpc"
    subnet_cidrs        = ["10.10.0.0/24", "10.10.1.0/24"]
    subnet_tags         = ["ansible_subnet_1", "ansible_subnet_2"]
    azs                 = ["us-east-1a", "us-east-1b"]
    igw_tag             = "ansible_igw"
    rt_tags             = ["ansible_rt"]
    rt_destination_cidr = "0.0.0.0/0"
    sg_tags             = ["ansible_sg"]
  }
}

variable "instance_details" {
  type = object({
    ami_id        = string
    key_pair      = string
    instance_type = string
    instance_tags = list(string)
  })
  default = {
    ami_id        = "ami-0778521d914d23bc1"
    key_pair      = "mac"
    instance_type = "t2.small"
    instance_tags = ["ansible_control_node_jenkins_instance", "ansible_node_instance"]
  }
}

variable "provisioner_variables" {
  type = object({
    connection_type = string
    user_name       = string
  })
  default = {
    connection_type = "ssh"
    user_name       = "ubuntu"
  }
}