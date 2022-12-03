# Creating Vpc
resource "aws_vpc" "lb_vpc" {
  cidr_block = var.network_details.cidr_block
  tags = {
    "Name" = var.network_details.vpc_name
  }
}

# Creating 2-Subnets
resource "aws_subnet" "lb_subnets" {
  count             = length(var.network_details.subnet_cidrs)
  vpc_id            = aws_vpc.lb_vpc.id
  cidr_block        = var.network_details.subnet_cidrs[count.index]
  availability_zone = var.network_details.availability_zones[count.index]
  tags = {
    "Name" = var.network_details.subnet_tags[count.index]
  }
  depends_on = [
    aws_vpc.lb_vpc
  ]
}

# Creating Internet Gateway
resource "aws_internet_gateway" "lb_igw" {
  vpc_id = aws_vpc.lb_vpc.id
  tags = {
    "Name" = var.network_details.internet_gateway_name
  }
  depends_on = [
    aws_vpc.lb_vpc
  ]
}


# Creating Route Table
resource "aws_route_table" "lb_rt" {
  vpc_id = aws_vpc.lb_vpc.id
  tags = {
    "Name" = var.network_details.route_table_name
  }
  depends_on = [
    aws_vpc.lb_vpc
  ]
}


# Creating Route
resource "aws_route" "lb_route" {
  route_table_id         = aws_route_table.lb_rt.id
  gateway_id             = aws_internet_gateway.lb_igw.id
  destination_cidr_block = var.network_details.destination_cidr
}


# Associating Subnets to Route Tables
resource "aws_route_table_association" "subnet_assoc" {
  count          = length(var.network_details.subnet_cidrs)
  route_table_id = aws_route_table.lb_rt.id
  subnet_id      = aws_subnet.lb_subnets[count.index].id
  depends_on = [
    aws_route_table.lb_rt
  ]
}

# creating Security Group
resource "aws_security_group" "lb_sg" {
  vpc_id = aws_vpc.lb_vpc.id
  ingress {
    cidr_blocks = [var.network_details.destination_cidr]
    description = "open ssh"
    from_port   = 22
    protocol    = var.network_details.protocol
    to_port     = 22
  }
  ingress {
    cidr_blocks = [var.network_details.destination_cidr]
    description = "open http"
    from_port   = 80
    protocol    = var.network_details.protocol
    to_port     = 80
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.network_details.destination_cidr]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    "Name" = var.network_details.security_group_name
  }
}

# Creating EC2 Instances
resource "aws_instance" "lb_instances" {
  count                       = length(var.instances_details.instance_tags)
  ami                         = var.instances_details.ami_id
  associate_public_ip_address = true
  availability_zone           = var.network_details.availability_zones[count.index]
  subnet_id                   = aws_subnet.lb_subnets[count.index].id
  instance_type               = var.instances_details.instance_type
  key_name                    = var.instances_details.key_pair
  security_groups             = [aws_security_group.lb_sg.id]
  tags = {
    "Name" = var.instances_details.instance_tags[count.index]
  }
}

resource "aws_lb_target_group" "lb_tg" {
  target_type = var.load_balancer_details.target_type
  protocol    = "HTTP"
  port        = 80
  vpc_id      = aws_vpc.lb_vpc.id
  tags = {
    "Name" = var.load_balancer_details.target_group_name
  }
  health_check {
    enabled  = true
    path     = "/"
    port     = 80
    protocol = "HTTP"
  }
}

resource "aws_lb_target_group_attachment" "tg_attachment" {
  count            = length(var.instances_details.instance_tags)
  target_group_arn = aws_lb_target_group.lb_tg.arn
  target_id        = aws_instance.lb_instances[count.index].id
  port             = 80
  depends_on = [
    aws_lb_target_group.lb_tg
  ]
}

resource "aws_lb" "alb_tf" {
    load_balancer_type = var.load_balancer_details.load_balancer_type
    internal = false
    security_groups = [aws_security_group.lb_sg.id]
    subnets = [ aws_subnet.lb_subnets[0].id, aws_subnet.lb_subnets[1].id ]
    tags = {
      "Name" = var.load_balancer_details.load_balancer_name
    }
    depends_on = [
      aws_lb_target_group.lb_tg
    ]
}

resource "aws_lb_listener" "alb_listener" {
    default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.lb_tg.arn
    }
    load_balancer_arn = aws_lb.alb_tf.arn
    port = 80
    protocol = "HTTP"
    tags = {
      "Name" = "Listner-1"
    }
}


