variable "region" {
  type = string
}

variable "network_details" {
  type = object({
    cidr_block            = string
    vpc_name              = string
    subnet_cidrs          = list(string)
    availability_zones    = list(string)
    subnet_tags           = list(string)
    internet_gateway_name = string
    route_table_name      = string
    destination_cidr      = string
    security_group_name   = string
    protocol              = string
  })
}

variable "instances_details" {
  type = object({
    ami_id        = string
    instance_type = string
    key_pair      = string
    instance_tags = list(string)
  })
}

variable "load_balancer_details" {
    type = object({
        target_group_name = string
        target_type = string
        load_balancer_type = string
        load_balancer_name = string
    })
  
}
