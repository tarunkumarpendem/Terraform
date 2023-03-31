resource "aws_vpc" "my_vpc" {
    cidr_block = var.network_details.vpc_cidr
    tags = {
      "Name" = var.network_details.vpc_tag
    }  
}

resource "aws_subnet" "my_subnets" {
    count = length(var.network_details.subnet_cidrs)
    cidr_block = var.network_details.subnet_cidrs[count.index]
    vpc_id = aws_vpc.my_vpc.id
    availability_zone = var.network_details.azs[count.index]
    tags = {
      "Name" = var.network_details.subnet_tags[count.index]
    }
    depends_on = [
      aws_vpc.my_vpc
    ]
}

resource "aws_internet_gateway" "my_igw" {
    vpc_id = aws_vpc.my_vpc.id
    tags = {
      "Name" = var.network_details.igw_tag
    }
    depends_on = [
      aws_vpc.my_vpc
    ]
}

resource "aws_route_table" "my_rts" {
    vpc_id = aws_vpc.my_vpc.id
    count = length(var.network_details.rt_tags)
    tags = {
      "Name" = var.network_details.rt_tags[count.index]
    }
    depends_on = [
      aws_vpc.my_vpc
    ]
}

resource "aws_route" "igw_route" {
    route_table_id = aws_route_table.my_rts[0].id
    destination_cidr_block = var.network_details.rt_destination_cidr
    gateway_id = aws_internet_gateway.my_igw.id
    depends_on = [
      aws_route_table.my_rts
    ] 
}

resource "aws_eip" "my_eip" {
    tags = {
      "Name" = var.network_details.elastic_ip_tag
    }
}

resource "aws_nat_gateway" "my_nat" {
    allocation_id = aws_eip.my_eip.allocation_id
    subnet_id = aws_subnet.my_subnets[0].id
    tags = {
      "Name" = var.network_details.nat_gateway_tag
    }
    depends_on = [
      aws_subnet.my_subnets
    ]
}



resource "aws_route" "nat_route" {
    route_table_id = aws_route_table.my_rts[1].id
    destination_cidr_block = var.network_details.rt_destination_cidr
    nat_gateway_id = aws_nat_gateway.my_nat.id
    depends_on = [
      aws_route_table.my_rts
    ] 
}

resource "aws_route_table_association" "igw_assc_1" {
    route_table_id = aws_route_table.my_rts[0].id
    subnet_id = aws_subnet.my_subnets[0].id
    depends_on = [
      aws_route_table.my_rts
    ]
}

resource "aws_route_table_association" "igw_assc_2" {
    route_table_id = aws_route_table.my_rts[0].id
    subnet_id = aws_subnet.my_subnets[1].id
    depends_on = [
      aws_route_table.my_rts
    ]
}

resource "aws_route_table_association" "nat_assc_1" {
    route_table_id = aws_route_table.my_rts[1].id
    subnet_id = aws_subnet.my_subnets[2].id
    depends_on = [
      aws_route_table.my_rts
    ]
}

resource "aws_route_table_association" "nat_assc_2" {
    route_table_id = aws_route_table.my_rts[1].id
    subnet_id = aws_subnet.my_subnets[3].id
    depends_on = [
      aws_route_table.my_rts
    ]
}

resource "aws_security_group" "my_sg_pub" {
  vpc_id = aws_vpc.my_vpc.id
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
    aws_vpc.my_vpc
  ]
}

resource "aws_security_group" "my_sg_pvt" {
  vpc_id = aws_vpc.my_vpc.id
  ingress {
    cidr_blocks = [var.network_details.rt_destination_cidr]
    description = "open ssh"
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
  }
  ingress {
    cidr_blocks = [var.network_details.rt_destination_cidr]
    description = "open all"
    from_port   = 0
    protocol    = "tcp"
    to_port     = 65535
  }
  ingress {
  cidr_blocks = [var.network_details.rt_destination_cidr]
  description = "open http"
  from_port   = 80
  protocol    = "tcp"
  to_port     = 80
}
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.network_details.rt_destination_cidr]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    "Name" = var.network_details.sg_tags[1]
  }
  depends_on = [
    aws_vpc.my_vpc
  ]
}

resource "aws_instance" "pub_instance" {
  ami = var.instance_details.ami_id
  key_name = var.instance_details.key_pair
  availability_zone = var.network_details.azs[0]
  associate_public_ip_address = true 
  instance_type = var.instance_details.instance_type
  security_groups = [ aws_security_group.my_sg_pub.id ]
  subnet_id = aws_subnet.my_subnets[0].id
  tags = {
    "Name" = var.instance_details.instance_tags[0]
  }
  depends_on = [
    aws_security_group.my_sg_pub
  ]
}

resource "aws_instance" "pvt_instance" {
  ami = var.instance_details.ami_id
  key_name = var.instance_details.key_pair
  availability_zone = var.network_details.azs[2]
  associate_public_ip_address = false 
  instance_type = var.instance_details.instance_type
  security_groups = [ aws_security_group.my_sg_pvt.id ]
  subnet_id = aws_subnet.my_subnets[2].id
  tags = {
    "Name" = var.instance_details.instance_tags[1]
  }
  depends_on = [
    aws_security_group.my_sg_pvt
  ]
}

resource "null_resource" "null" {
  triggers = {
    "Name" = var.provisioner_variables.null_trigger
  }
  provisioner "remote-exec" {
    connection {
      type        = var.provisioner_variables.connection_type
      host        = aws_instance.pub_instance.public_ip
      user        = var.provisioner_variables.user_name
      private_key = file("~/.ssh/id_rsa")
    }
    inline = [
      "sudo apt update",
      "sudo apt install apache2 -y"
    ]
  }
  provisioner "remote-exec" {
    connection {
      type                = var.provisioner_variables.connection_type
      host                = aws_instance.pvt_instance.private_ip
      user                = var.provisioner_variables.user_name
      private_key         = file("~/.ssh/id_rsa")
      bastion_host        = aws_instance.pub_instance.public_ip
      bastion_host_key    = file("~/.ssh/id_rsa.pub")
      bastion_user        = var.provisioner_variables.user_name
      bastion_private_key = file("~/.ssh/id_rsa")
    }
    inline = [
      "sudo apt update",
      "sudo apt install nginx -y",
      "sudo apt install software-properties-common -y",
      "sudo add-apt-repository --yes --update ppa:ansible/ansible",
      "sudo apt install ansible -y"
    ]
  }
  depends_on = [
    aws_nat_gateway.my_nat
  ]
}


resource "aws_lb_target_group" "tg" {
  name        = var.load_balancer_details.target_group_name
  port        = var.load_balancer_details.port
  protocol    = var.load_balancer_details.protocol
  vpc_id      = aws_vpc.my_vpc.id
  target_type = var.load_balancer_details.target_type
  health_check {
    enabled  = true
    protocol = var.load_balancer_details.protocol
    port     = var.load_balancer_details.port
    path     = "/"
  }
  tags = {
    "Name" = var.load_balancer_details.target_group_tag
  }
  depends_on = [
    aws_instance.pvt_instance
  ]
}

resource "aws_lb_target_group_attachment" "TG_Attach1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.pub_instance.id
  port             = var.load_balancer_details.port
  #availability_zone = var.availability_zone[0]
  depends_on = [
    aws_lb_target_group.tg
  ]
}

resource "aws_lb_target_group_attachment" "TG_Attach2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.pvt_instance.id
  port             = var.load_balancer_details.port
  #availability_zone = var.availability_zone[0]
  depends_on = [
    aws_lb_target_group.tg
  ]
}

resource "aws_lb" "app_lb" {
  name               = var.load_balancer_details.load_balancer_name
  internal           = false
  load_balancer_type = var.load_balancer_details.load_balancer_type
  security_groups    = [ aws_security_group.my_sg_pvt.id ]
  subnets            = [aws_subnet.my_subnets[0].id, aws_subnet.my_subnets[2].id]
  tags = {
    "Name" = var.load_balancer_details.load_balancer_tag
  }
  depends_on = [
    aws_lb_target_group.tg
  ]
}

# create listener
resource "aws_lb_listener" "alb_listener" {
  default_action {
    type             = var.load_balancer_details.load_balancer_listner_type
    target_group_arn = aws_lb_target_group.tg.arn
  }
  load_balancer_arn = aws_lb.app_lb.arn
  port              = var.load_balancer_details.port
  protocol          = var.load_balancer_details.protocol
  tags = {
    "Name" = var.load_balancer_details.listener_tag
  }
}


