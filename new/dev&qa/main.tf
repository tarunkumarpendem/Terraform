# create vpc
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_details.cidr_block
  tags = {
    "Name" = var.vpc_details.vpc_tag
  }
}

# create subnets
resource "aws_subnet" "subnets" {
  vpc_id            = aws_vpc.vpc.id
  count             = length(var.subnet_details.subnet_cidrs)
  availability_zone = var.subnet_details.azs[count.index]
  cidr_block        = var.subnet_details.subnet_cidrs[count.index]
  tags = {
    "Name" = var.subnet_details.subnet_tags[count.index]
  }
  depends_on = [
    aws_vpc.vpc
  ]
}

# Internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Name" = "IGW"
  }
  depends_on = [
    aws_vpc.vpc
  ]
}


# create route table
resource "aws_route_table" "route_table" {
  count  = length(var.rt_details.route_table_tags)
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Name" = var.rt_details.route_table_tags[count.index]
  }
  depends_on = [
    aws_vpc.vpc
  ]
}


# create route
resource "aws_route" "route" {
  count                  = length(var.rt_details.route_table_tags)
  route_table_id         = aws_route_table.route_table[0].id
  destination_cidr_block = var.vpc_details.destination_cidr
  gateway_id             = aws_internet_gateway.igw.id
  depends_on = [
    aws_route_table.route_table
  ]
}

# subnet association
resource "aws_route_table_association" "assc_subnet1" {
  route_table_id = aws_route_table.route_table[0].id
  subnet_id      = aws_subnet.subnets[0].id
}
resource "aws_route_table_association" "assc_subnet2" {
  route_table_id = aws_route_table.route_table[1].id
  subnet_id      = aws_subnet.subnets[1].id
}

# Create Security Group
resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.vpc.id
   ingress {
    cidr_blocks = [var.vpc_details.destination_cidr]
    description = "open ssh"
    from_port   = "22"
    protocol    = "tcp"
    to_port     = "22"
  }
  ingress {
    cidr_blocks = [var.vpc_details.destination_cidr]
    description = "open http"
    from_port   = "80"
    protocol    = "tcp"
    to_port     = "80"
  }
  ingress {
    cidr_blocks = [var.vpc_details.destination_cidr]
    description = "open 8080"
    from_port   = "8080"
    protocol    = "tcp"
    to_port     = "8080"
  }
  ingress {
    cidr_blocks = [var.vpc_details.destination_cidr]
    description = "open 8081"
    from_port   = "8081"
    protocol    = "tcp"
    to_port     = "8081"
  }
  ingress {
    cidr_blocks = [var.vpc_details.destination_cidr]
    description = "open 4200"
    from_port   = "4200"
    protocol    = "tcp"
    to_port     = "4200"
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    "Name" = "env_sg"
  }
}

# create dev ec2 instance
resource "aws_instance" "dev_ec2" {
    count = "${terraform.workspace == "default" ? 1 : 0}" 
    ami = var.instance_details.ami_id
    key_name = var.instance_details.key_pair
    instance_type = var.instance_details.instance_type
    security_groups = [aws_security_group.sg.id]
    subnet_id = aws_subnet.subnets[0].id
    associate_public_ip_address = true
    availability_zone = var.subnet_details.azs[0]
    tags = {
      "Name" = "dev"
    }
}

# create qa ec2 instance
resource "aws_instance" "qa_ec2" {
    count = "${terraform.workspace == "qa" ? 2 : 0}" 
    ami = var.instance_details.ami_id
    key_name = var.instance_details.key_pair
    instance_type = var.instance_details.instance_type
    security_groups = [aws_security_group.sg.id]
    subnet_id = aws_subnet.subnets[1].id
    associate_public_ip_address = false
    availability_zone = var.subnet_details.azs[1]
    tags = {
      "Name" = var.instance_details.qa_instance_tags[count.index]
    }
}

# create target group
resource "aws_lb_target_group" "tg" {
  count = "${terraform.workspace == "qa" ? 1 : 0}"
  name        = "TargetGroup"
  port        = "80"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "instance"
  health_check {
    enabled  = true
    protocol = "HTTP"
    port     = "80"
    path     = "/"
  }
  tags = {
    "Name" = "TargetGroup"
  }
  depends_on = [
    aws_vpc.vpc
  ]
}

resource "aws_lb_target_group_attachment" "TG_Attach1" {
  target_group_arn = aws_lb_target_group.tg[0].arn
  target_id        = aws_instance.qa_ec2[0].id
  port             = "80"
  #availability_zone = var.availability_zone[0]
  depends_on = [
    aws_lb_target_group.tg
  ]
}

resource "aws_lb_target_group_attachment" "TG_Attach2" {
  target_group_arn = aws_lb_target_group.tg[0].arn
  target_id        = aws_instance.qa_ec2[1].id
  port             = "80"
  #availability_zone = var.availability_zone[0]
  depends_on = [
    aws_lb_target_group.tg
  ]
}

resource "aws_lb" "qa_alb" {
  count = "${terraform.workspace == "qa" ? 1 : 0}"
  name               = "qa-ApplicationLoadBalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id]
  subnets            = [aws_subnet.subnets[0].id, aws_subnet.subnets[1].id]
  tags = {
    "Environment" = "qa"
  }
  depends_on = [
    aws_lb_target_group.tg
  ]
}

# create listener
resource "aws_lb_listener" "qa_alb_listener" {
  count = "${terraform.workspace == "qa" ? 1 : 0}"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg[0].arn
  }
  load_balancer_arn = aws_lb.qa_alb[0].arn
  port              = "80"
  protocol          = "HTTP"
  tags = {
    "Name" = "Listener-1"
  }
}