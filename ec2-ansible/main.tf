resource "aws_vpc" "ansible_vpc" {
  cidr_block = var.network_details.vpc_cidr
  tags = {
    "Name" = var.network_details.vpc_tag
  }
}

resource "aws_subnet" "ansible_subnets" {
  count             = length(var.network_details.subnet_cidrs)
  cidr_block        = var.network_details.subnet_cidrs[count.index]
  vpc_id            = aws_vpc.ansible_vpc.id
  availability_zone = var.network_details.azs[count.index]
  tags = {
    "Name" = var.network_details.subnet_tags[count.index]
  }
  depends_on = [
    aws_vpc.ansible_vpc
  ]
}

resource "aws_internet_gateway" "ansible_igw" {
  vpc_id = aws_vpc.ansible_vpc.id
  tags = {
    "Name" = var.network_details.igw_tag
  }
  depends_on = [
    aws_vpc.ansible_vpc
  ]
}

resource "aws_route_table" "ansible_rt" {
  vpc_id = aws_vpc.ansible_vpc.id
  count  = length(var.network_details.rt_tags)
  tags = {
    "Name" = var.network_details.rt_tags[count.index]
  }
  depends_on = [
    aws_vpc.ansible_vpc
  ]
}

resource "aws_route" "igw_route" {
  route_table_id         = aws_route_table.ansible_rt[0].id
  destination_cidr_block = var.network_details.rt_destination_cidr
  gateway_id             = aws_internet_gateway.ansible_igw.id
  depends_on = [
    aws_route_table.ansible_rt[0]
  ]
}

resource "aws_route_table_association" "igw_assc_1" {
  route_table_id = aws_route_table.ansible_rt[0].id
  subnet_id      = aws_subnet.ansible_subnets[0].id
  depends_on = [
    aws_route_table.ansible_rt
  ]
}

resource "aws_route_table_association" "igw_assc_2" {
  route_table_id = aws_route_table.ansible_rt[0].id
  subnet_id      = aws_subnet.ansible_subnets[1].id
  depends_on = [
    aws_route_table.ansible_rt
  ]
}

resource "aws_security_group" "ansible_sg" {
  vpc_id = aws_vpc.ansible_vpc.id
  ingress {
    cidr_blocks = [var.network_details.rt_destination_cidr]
    description = "open ssh"
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
  }
  ingress {
    cidr_blocks = [var.network_details.rt_destination_cidr]
    description = "open http"
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
  }
  ingress {
    cidr_blocks = [var.network_details.rt_destination_cidr]
    from_port   = 8080
    protocol    = "tcp"
    to_port     = 8080
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.network_details.rt_destination_cidr]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    "Name" = var.network_details.sg_tags[0]
  }
  depends_on = [
    aws_vpc.ansible_vpc
  ]
}

resource "aws_instance" "ansible_control_node_instance" {
  ami                         = var.instance_details.ami_id
  key_name                    = var.instance_details.key_pair
  availability_zone           = var.network_details.azs[0]
  associate_public_ip_address = true
  instance_type               = var.instance_details.instance_type
  security_groups             = [aws_security_group.ansible_sg.id]
  subnet_id                   = aws_subnet.ansible_subnets[0].id
  tags = {
    "Name" = var.instance_details.instance_tags[0]
  }
  provisioner "file" {
    source      = "~/.ssh/id_rsa"
    destination = "/home/ubuntu/.ssh/id_rsa"
    connection {
      type        = var.provisioner_variables.connection_type
      user        = var.provisioner_variables.user_name
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }
  }
  provisioner "file" {
    source      = "./jenkins.yaml"
    destination = "/home/ubuntu/jenkins.yaml"
    connection {
      type        = var.provisioner_variables.connection_type
      user        = var.provisioner_variables.user_name
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }
  }

  provisioner "file" {
    source      = "./jenkins.ini"
    destination = "/home/ubuntu/jenkins.ini"
    connection {
      type        = var.provisioner_variables.connection_type
      user        = var.provisioner_variables.user_name
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }
  }

  provisioner "remote-exec" {
    connection {
      type        = var.provisioner_variables.connection_type
      user        = var.provisioner_variables.user_name
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }
    inline = [
      "chmod 600 /home/ubuntu/.ssh/id_rsa",
      "export ANSIBLE_HOST_KEY_CHECKING=False",
      "sudo apt update",
      "sudo apt install software-properties-common -y",
      "sudo add-apt-repository --yes --update ppa:ansible/ansible",
      "sudo apt install ansible -y",
      "sudo apt install net-tools -y",
      "export PRIVATE_IP=$(ip a | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d'/' -f1)",
      "echo $PRIVATE_IP",
      "ip a | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d'/' -f1 > hosts",
      "pwd && ls -al",
      "ansible-playbook -i hosts jenkins.yaml",
      "sudo cat /home/jenkins/.jenkins/secrets/initialAdminPassword"
    ]
  }
  depends_on = [
    aws_security_group.ansible_sg
  ]
}