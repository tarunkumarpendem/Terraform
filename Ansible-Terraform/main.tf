resource "aws_security_group" "ansible_sg" {
  name        = "Lampstack security group"
  description = "Allow ssh and http from anywhere"
  vpc_id      = "vpc-062a45b167fb7c088"

  ingress {
    description = "openssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "open http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "lampstack_sg"
  }
}


module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  #   count = 2
  #   name = var.ec2_details.instance_tags[count.index]

  ami                    = var.ec2_details.ami_id
  instance_type          = var.ec2_details.instance_type
  key_name               = var.ec2_details.key_pair
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.ansible_sg.id]
  subnet_id              = var.ec2_details.subnet_id

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Name        = var.ec2_details.instance_tag
  }
}

resource "null_resource" "null" {
  triggers = {
    "Name" = var.ec2_details.trigger
  }
 connection {
          type = "ssh"
          user = "ubuntu"
          private_key = file("~/.ssh/id_rsa")
          host = module.ec2_instance.public_ip
        }
  provisioner "file" {
    source      = "./hosts"
    destination = "/home/ubuntu/hosts"

  }
  provisioner "file" {
    source      = "./info.php"
    destination = "/home/ubuntu/info.php"
  }
  provisioner "file" {
    source      = "./lampstack.yaml"
    destination = "/home/ubuntu/lampstack.yaml"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt-add-repository ppa:ansible/ansible -y",
      "sudo apt-get install ansible -y",
      "ansible-playbook -i hosts lampstack.yaml"
    ]
  }
}
