variable "region" {
    type = string
    default = "us-west-2"  
}

variable "network_details" {
    type = object({
        cidr_block = string
        vpc_tag   = string
        subnet_cidrs = list(string)
        azs = list(string)
        subnet_tags = list(string)
        internet_gateway_tag = string
        security_group_tag = string
        elastic_ip_tag = string
        nat_gateway_tag = string
    }) 
}

variable "route_table_details" {
    type = object({
        route_table_tags = list(string)
        destination_cidr = string
    })
}

variable "instance_details" {
    type = object({
        ami_id = string
        key_pair = string
        instance_type = string
        instance_tags = list(string)
        null_trigger  = string
    }) 
}

variable "load_balancer_details" {
    type = object({
        target_group_tag = string
        load_balancer_tag = string
        load_balancer_type = string
    })
  
}