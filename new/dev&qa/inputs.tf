variable "region" {
  type = string
}

variable "vpc_details" {
  type = object({
    cidr_block = string
    vpc_tag    = string
    destination_cidr = string
  })
}

variable "subnet_details" {
    type = object({
        subnet_cidrs = list(string)
        azs =  list(string)
        subnet_tags = list(string)
    })
}

variable "rt_details" {
    type = object({
        route_table_tags = list(string)
    })
  
}