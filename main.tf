resource "aws_vpc" "bastion_vpc" {
  cidr_block = var.network_details.cidr_block
  tags = {
    "Name" = var.network_details.vpc_tag
  }
}

resource "aws_subnet" "bastion_subnets" {
  count             = length(var.network_details.subnet_cidrs)
  vpc_id            = aws_vpc.bastion_vpc.id
  cidr_block        = var.network_details.subnet_cidrs[count.index]
  availability_zone = var.network_details.azs[count.index]
  tags = {
    "Name" = var.network_details.subnet_tags[count.index]
  }
  depends_on = [
    aws_vpc.bastion_vpc
  ]
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.bastion_vpc.id
  tags = {
    "Name" = var.network_details.internet_gateway_tag
  }
}

resource "aws_eip" "elastic_ip" {
  tags = {
    "Name" = var.network_details.elastic_ip_tag
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.elastic_ip.allocation_id
  subnet_id     = aws_subnet.bastion_subnets[0].id
  tags = {
    "Name" = var.network_details.nat_gateway_tag
  }
}

resource "aws_route_table" "bastion_route_tables" {
  count  = length(var.route_table_details.route_table_tags)
  vpc_id = aws_vpc.bastion_vpc.id
  tags = {
    "Name" = var.route_table_details.route_table_tags[count.index]
  }
  depends_on = [
    aws_vpc.bastion_vpc
  ]
}

resource "aws_route" "igw_route" {
  route_table_id         = aws_route_table.bastion_route_tables[0].id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = var.route_table_details.destination_cidr
  depends_on = [
    aws_route_table.bastion_route_tables
  ]
}

resource "aws_route" "nat_route" {
  route_table_id         = aws_route_table.bastion_route_tables[1].id
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
  destination_cidr_block = var.route_table_details.destination_cidr
  depends_on = [
    aws_route_table.bastion_route_tables
  ]
}

resource "aws_route_table_association" "subnet_association_1" {
  route_table_id = aws_route_table.bastion_route_tables[0].id
  subnet_id      = aws_subnet.bastion_subnets[0].id
  depends_on = [
    aws_route_table.bastion_route_tables
  ]
}

resource "aws_route_table_association" "subnet_association_2" {
  route_table_id = aws_route_table.bastion_route_tables[1].id
  subnet_id      = aws_subnet.bastion_subnets[1].id
  depends_on = [
    aws_route_table.bastion_route_tables
  ]
}

resource "aws_security_group" "bastion_sg" {
  vpc_id = aws_vpc.bastion_vpc.id
  ingress {
    cidr_blocks = [var.route_table_details.destination_cidr]
    description = "open ssh"
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
  }
  ingress {
    cidr_blocks = [var.route_table_details.destination_cidr]
    description = "open http"
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.route_table_details.destination_cidr]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    "Name" = var.network_details.security_group_tag
  }
}

resource "aws_instance" "public_instance" {
  ami                         = var.instance_details.ami_id
  key_name                    = var.instance_details.key_pair
  security_groups             = [aws_security_group.bastion_sg.id]
  subnet_id                   = aws_subnet.bastion_subnets[0].id
  availability_zone           = var.network_details.azs[0]
  instance_type               = var.instance_details.instance_type
  associate_public_ip_address = true
  tags = {
    "Name" = var.instance_details.instance_tags[0]
  }
}

resource "aws_instance" "private_instance" {
  ami                         = var.instance_details.ami_id
  key_name                    = var.instance_details.key_pair
  security_groups             = [aws_security_group.bastion_sg.id]
  subnet_id                   = aws_subnet.bastion_subnets[1].id
  availability_zone           = var.network_details.azs[1]
  instance_type               = var.instance_details.instance_type
  associate_public_ip_address = false
  tags = {
    "Name" = var.instance_details.instance_tags[1]
  }
}

resource "null_resource" "null" {
  triggers = {
    "Name" = var.instance_details.null_trigger
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = aws_instance.public_instance.public_ip
      user        = "ubuntu"
      private_key = file("~/id_rsa")
    }
    inline = [
      "sudo apt update",
      "sudo apt install apache2 -y"
    ]
  }
  provisioner "remote-exec" {
    connection {
      type                = "ssh"
      host                = aws_instance.private_instance.private_ip
      user                = "ubuntu"
      private_key         = file("~/id_rsa")
      bastion_host        = aws_instance.public_instance.public_ip
      bastion_host_key    = file("~/id_rsa.pub")
      bastion_user        = "ubuntu"
      bastion_private_key = file("~/id_rsa")
    }
    inline = [
      "sudo apt update",
      "sudo apt install nginx -y"
    ]
  }
  depends_on = [
    aws_nat_gateway.nat_gateway
  ]
}

# create target group
resource "aws_lb_target_group" "tg" {
  name        = var.load_balancer_details.target_group_name
  port        = var.load_balancer_details.port
  protocol    = var.load_balancer_details.protocol
  vpc_id      = aws_vpc.bastion_vpc.id
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
    aws_instance.private_instance
  ]
}

resource "aws_lb_target_group_attachment" "TG_Attach1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.public_instance.id
  port             = var.load_balancer_details.port
  #availability_zone = var.availability_zone[0]
  depends_on = [
    aws_lb_target_group.tg
  ]
}

resource "aws_lb_target_group_attachment" "TG_Attach2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.private_instance.id
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
  security_groups    = [aws_security_group.bastion_sg.id]
  subnets            = [aws_subnet.bastion_subnets[0].id, aws_subnet.bastion_subnets[1].id]
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

