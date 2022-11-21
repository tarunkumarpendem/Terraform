variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_detatils" {
  type    = object({
    vpc_cidr  = list(string)
    vpc_tags  = list(string)

  })
}

variable "subnet_cidr" {
  type    = string
  default = "192.168.0.0/24"
}

variable "availability_zone" {
  type = string
}

variable "destination_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

variable "Keypair" {
  type    = string
  default = "srandard"
}


variable "ec2_details" {
  type = object({
    ami_id        = string
    instance_type = string
    keypair       = string
  })
}

variable "trigger_number" {
  type = string
}

variable "vpc_env_count" {
  type = string
}
