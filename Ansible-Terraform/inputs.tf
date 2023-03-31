variable "ec2_details" {
    type = object({
        ami_id =  string
        instance_type = string
        key_pair = string
        subnet_id = string
        trigger = string
        instance_tag = string
    }) 
}