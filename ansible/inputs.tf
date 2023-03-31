# variable "ec2_details" {
#     type = object({
#         ami_id =  string
#         instance_type = string
#         key_pair = string
#         security_group_id = string
#         subnet_id = string
#         trigger = string
#         instance_tags = list(string)
#     }) 
# }

variable "provisioner_variables" {
    type = object({
        null_trigger = string
        user_name = string
        connection_type = string
        user_password = string
        host_ip = string
    }) 
}