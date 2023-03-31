# module "ec2_instance" {
#   source  = "terraform-aws-modules/ec2-instance/aws"
#   version = "~> 3.0"

#   count = 2
#   name = var.ec2_details.instance_tags[count.index]

#   ami                    = var.ec2_details.ami_id
#   instance_type          = var.ec2_details.instance_type
#   key_name               = var.ec2_details.key_pair
#   monitoring             = true
#   vpc_security_group_ids = [ var.ec2_details.security_group_id ]
#   subnet_id              = var.ec2_details.subnet_id

#   tags = {
#     Terraform   = "true"
#     Environment = "dev"
#   }
# }

# resource "null_resource" "null" {
#     triggers = {
#       "Name" = var.ec2_details.trigger
#     }
#     provisioner "remote-exec" {
#         connection {
#           type = "ssh"
#           user = "ubuntu"
#           private_key = file("~/.ssh/id_rsa")
#           host = module.ec2_instance[0].public_ip
#         }
#         inline = [
#           "sudo apt update",
#           "sudo apt install software-properties-common -y",
#           "sudo add-apt-repository --yes --update ppa:ansible/ansible",
#           "sudo apt install ansible nginx -y"
#         ] 
#     }
# }

resource "null_resource" "ansible" {
    triggers = {
      "Name" = var.provisioner_variables.null_trigger
    }
    provisioner "remote-exec" {
        connection {
          type = var.provisioner_variables.connection_type
          user = var.provisioner_variables.user_name
          password = var.provisioner_variables.user_password
          host = var.provisioner_variables.host_ip
        }
        inline = [
          "ansible --version",
          "ansible -i hosts.yaml -m ping all",
          "ansible-playbook -i hosts.yaml playbook.yaml"
        ] 
    }
}

