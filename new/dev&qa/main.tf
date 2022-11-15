# create vpc
resource "aws_vpc" "vpc" {
    cidr_block = var.vpc_details.cidr_block
    tags = {
      "Name" = var.vpc_details.vpc_tag
    }
}

# create subnets
resource "aws_subnet" "subnets" {
     vpc_id = aws_vpc.vpc.id
     count = length(var.subnet_details.subnet_cidrs)
     availability_zone = var.subnet_details.azs[count.index]
     cidr_block = var.subnet_details.subnet_cidrs[count.index]
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
    count = length(var.rt_details.route_table_tags)
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
    count = length(var.rt_details.route_table_tags)
    route_table_id = aws_route_table.route_table[0].id
    destination_cidr_block = var.vpc_details.destination_cidr   
    gateway_id = aws_internet_gateway.igw.id
    depends_on = [
      aws_route_table.route_table
    ]
}

# subnet association
resource "aws_route_table_association" "assc_subnet1" {
    route_table_id = aws_route_table.route_table[0].id
    subnet_id = aws_subnet.subnets[0].id
  
}