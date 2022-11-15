# create qa Group
#--------------------------

# Create VPC
resource "aws_vpc" "qa_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    "Name" = "Qa_Vpc"
  }
}


# Create Subnets
resource "aws_subnet" "qa_subnet" {
  count = length(var.subnet_cidr)
  cidr_block        = var.subnet_cidr[count.index]
  availability_zone = var.availability_zone[count.index]
  vpc_id            = aws_vpc.qa_vpc.id
  tags = {
    "Name" = "Qa_App_Subnet"
  }
  depends_on = [
    aws_vpc.qa_vpc
  ]
}


# InternetGateWay
resource "aws_internet_gateway" "qa_igw" {
  vpc_id = aws_vpc.qa_vpc.id
  tags = {
    "Name" = "qa_igw"
  } 
}


# Create Route Table
resource "aws_route_table" "qa_Rtb" {
  count = var.rt_details.count
  vpc_id = aws_vpc.qa_vpc.id
  tags = {
    "Name" = var.rt_details.rt_tags[count.index]
  }
  depends_on = [
    aws_vpc.qa_vpc
  ]
}


# allocate elastic ip
resource "aws_eip" "elastic_ip" {
  network_border_group = var.region
}

# create NAT Gateway
resource "aws_nat_gateway" "qa_NAT" {
  allocation_id = aws_eip.elastic_ip.allocation_id
  subnet_id = aws_subnet.qa_subnet[0].id
  tags = {
    "Name" = "qa_NAT"
  }
}


# Create Route to Pub Route Table
resource "aws_route" "qa_nat_route" {
  route_table_id         = aws_route_table.qa_Rtb[0].id
  destination_cidr_block = var.destination_cidr
  gateway_id = aws_internet_gateway.qa_igw.id 
}

# create Route to pvt Route table
resource "aws_route" "qt_igw_route" {
    route_table_id = aws_route_table.qa_Rtb[1].id
    destination_cidr_block = var.destination_cidr
    nat_gateway_id         = aws_nat_gateway.qa_NAT.id
    
}

# Associate Subnet to Pub Route Table
resource "aws_route_table_association" "assc_subnet1" {
  subnet_id      = aws_subnet.qa_subnet[0].id
  route_table_id = aws_route_table.qa_Rtb[0].id
  depends_on = [
     aws_route_table.qa_Rtb[1]
  ]
}

# # Associate Subnet to pvt Route Table
resource "aws_route_table_association" "assc_subnet2" {
  subnet_id      = aws_subnet.qa_subnet[1].id
  route_table_id = aws_route_table.qa_Rtb[1].id
  depends_on = [
    aws_route_table.qa_Rtb[1]
  ]
}

# Create Security Group
resource "aws_security_group" "qa_sg" {
  description = "This is the sg from terraform for qa environment"
  vpc_id      = aws_vpc.qa_vpc.id
  ingress {
    cidr_blocks = [var.destination_cidr]
    description = "open ssh"
    from_port   = "22"
    protocol    = "tcp"
    to_port     = "22"
  }
  ingress {
    cidr_blocks = [var.destination_cidr]
    description = "open http"
    from_port   = "80"
    protocol    = "tcp"
    to_port     = "80"
  }
  ingress {
    cidr_blocks = [var.destination_cidr]
    description = "open 8080"
    from_port   = "8080"
    protocol    = "tcp"
    to_port     = "8080"
  }
  ingress {
    cidr_blocks = [var.destination_cidr]
    description = "open 8081"
    from_port   = "8081"
    protocol    = "tcp"
    to_port     = "8081"
  }
  ingress {
    cidr_blocks = [var.destination_cidr]
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
    "Name" = "qa_sg"
  }
}


# create EC2 Instance
resource "aws_instance" "qa_ec2" {
  count                       = length(var.availability_zone)
  ami                         = var.ec2_details.ami_id
  instance_type               = var.ec2_details.instance_type
  key_name                    = var.ec2_details.keypair
  subnet_id                   = aws_subnet.qa_subnet[1].id
  availability_zone           = var.availability_zone[1]
  associate_public_ip_address = false
  security_groups             = [aws_security_group.qa_sg.id]
  tags = {
    "Name" = var.ec2_details.instance_tags[count.index]
  }
  depends_on = [
    aws_security_group.qa_sg
  ]
}

# data source
#data "aws_instance" "dev_instance" {
#       instance_id  = aws_instance.dev_ec2.id
  
#}
# null resource 
resource "null_resource" "qa_null" {
  triggers = {
    "trigger_number" = var.trigger_number
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = aws_instance.qa_ec2[0].private_ip
      private_key = file("~/.ssh/id_rsa")
      timeout = "4m"
    }
    inline = [
      "sudo apt update",
      "curl -sL https://deb.nodesource.com/setup_16.x | sudo bash -",
      "sudo apt -y install nodejs"
      /*"sudo -i",
      "git clone https://github.com/gothinkster/angular-realworld-example-app.git",
      "cd angular-realworld-example-app/",
      "npm install -g @angular/cli",
      "npm install",
      "ng serve --host "0.0.0.0"*/
    ]
  }
}


# create TargetGroup
resource "aws_lb_target_group" "qa_tg" {
  name        = "QATargetGroup"
  port        = "4200"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.qa_vpc.id
  target_type = "instance"
  health_check {
    enabled  = true
    protocol = "HTTP"
    port     = "4200"
    path     = "/"
  }
  tags = {
    "Name" = "QA_TargetGroup"
  }
  depends_on = [
    aws_vpc.qa_vpc
  ]
}


# Attach instance Target Group
resource "aws_lb_target_group_attachment" "QA_TG_Attach1" {
  target_group_arn = aws_lb_target_group.qa_tg.arn
  target_id        = aws_instance.qa_ec2[0].id
  port             = "4200"
  #availability_zone = var.availability_zone[0]
  depends_on = [
    aws_lb_target_group.qa_tg
  ]
}

# Attach instance Target Group
resource "aws_lb_target_group_attachment" "QA_TG_Attach2" {
  target_group_arn = aws_lb_target_group.qa_tg.arn
  target_id        = aws_instance.qa_ec2[1].id
  port             = "4200"
  #availability_zone = var.availability_zone[0]
  depends_on = [
    aws_lb_target_group.qa_tg
  ]
}

# create application load balancer
resource "aws_lb" "qa_alb" {
  name               = "qa-ApplicationLoadBalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.qa_sg.id]
  subnets            = [aws_subnet.qa_subnet[0].id, aws_subnet.qa_subnet[1].id]
  tags = {
    "Environment" = "qa"
  }
  depends_on = [
    aws_lb_target_group.qa_tg
  ]
}

# create listener
resource "aws_lb_listener" "qa_alb_listener" {
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.qa_tg.arn
  }
  load_balancer_arn = aws_lb.qa_alb.arn
  port              = "4200"
  protocol          = "HTTP"
  tags = {
    "Name" = "Listener-1"
  }
}



