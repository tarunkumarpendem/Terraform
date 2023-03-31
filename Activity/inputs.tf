variable "region" {
    type = string  
}

variable "network_details" {
    type = object({
        vpc_cidr = string
        vpc_tag = string
        subnet_cidrs = list(string)
        subnet_tags = list(string)
        azs = list(string)
        igw_tag = string
        rt_tags = list(string)
        rt_destination_cidr = string
        elastic_ip_tag = string
        nat_gateway_tag = string
        sg_tags = list(string)
    })
}

variable "instance_details" {
    type = object({
        ami_id = string
        key_pair = string
        instance_type = string
        instance_tags = list(string)
    }) 
}

variable "provisioner_variables" {
    type = object({
        null_trigger = string
        connection_type = string
        user_name = string
    }) 
}

variable "load_balancer_details" {
    type = object({
        target_group_name = string
        port = string
        protocol = string
        target_type = string
        target_group_tag = string
        load_balancer_name = string
        load_balancer_type = string
        load_balancer_tag = string
        load_balancer_listner_type = string
        listener_tag = string  
    })  
}