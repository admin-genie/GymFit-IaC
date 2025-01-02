locals {
  az-1 = "sa-east-1a"
  az-2 = "sa-east-1c"
}

# Create VPC
resource "aws_vpc" "def_vpc" {
  cidr_block = var.cidrBlock
  tags = {
    Name = "${var.naming}_vpc"
  }
}

# Create Public Subnet
resource "aws_subnet" "pub_a" {
  vpc_id            = aws_vpc.def_vpc.id
  cidr_block        = cidrsubnet(var.cidrBlock, 9, 0)
  availability_zone = local.az-1
  tags = {
    Name = "${var.naming}-pub-sub-a"
  }
}

resource "aws_subnet" "pub_c" {
  vpc_id            = aws_vpc.def_vpc.id
  cidr_block        = cidrsubnet(var.cidrBlock, 9, 1)
  availability_zone = local.az-2
  tags = {
    Name = "${var.naming}-pub-sub-c"
  }
}

# Create Private Subnet
resource "aws_subnet" "pri_app_a" {
  vpc_id            = aws_vpc.def_vpc.id
  cidr_block        = cidrsubnet(var.cidrBlock, 9, 2)
  availability_zone = local.az-1
  tags = {
    Name = "${var.naming}-pri-app-sub-a"
  }
}

resource "aws_subnet" "pri_app_c" {
  vpc_id            = aws_vpc.def_vpc.id
  cidr_block        = cidrsubnet(var.cidrBlock, 9, 3)
  availability_zone = local.az-2
  tags = {
    Name = "${var.naming}-pri-app-sub-c"
  }
}

resource "aws_subnet" "pri_db_a" {
  vpc_id            = aws_vpc.def_vpc.id
  cidr_block        = cidrsubnet(var.cidrBlock, 9, 4)
  availability_zone = local.az-1
  tags = {
    Name = "${var.naming}-pri-db-sub-a"
  }
}

resource "aws_subnet" "pri_db_c" {
  vpc_id            = aws_vpc.def_vpc.id
  cidr_block        = cidrsubnet(var.cidrBlock, 9, 5)
  availability_zone = local.az-2
  tags = {
    Name = "${var.naming}-pri-db-sub-c"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "def_igw" {
  vpc_id = aws_vpc.def_vpc.id
  tags = {
    Name = "${var.naming}_igw"
  }
}

# Create a Public Route table
resource "aws_route_table" "pub_rtb_a" {
  vpc_id = aws_vpc.def_vpc.id
  tags = {
    Name = "${var.naming}-pub-rtb-a"
  }
}

resource "aws_route_table" "pub_rtb_c" {
  vpc_id = aws_vpc.def_vpc.id
  tags = {
    Name = "${var.naming}-pub-rtb-c"
  }
}

# Create a APP Private Route table
resource "aws_route_table" "pri_app_rtb_a" {
  vpc_id = aws_vpc.def_vpc.id
  tags = {
    Name = "${var.naming}-pri-app-rtb-a"
  }
}

resource "aws_route_table" "pri_app_rtb_c" {
  vpc_id = aws_vpc.def_vpc.id
  tags = {
    Name = "${var.naming}-pri-app-rtb-c"
  }
}
# Create a DB Private Route table
resource "aws_route_table" "pri_db_rtb_a" {
  vpc_id = aws_vpc.def_vpc.id
  tags = {
    Name = "${var.naming}-pri-db-rtb-a"
  }
}

resource "aws_route_table" "pri_db_rtb_c" {
  vpc_id = aws_vpc.def_vpc.id
  tags = {
    Name = "${var.naming}_pri_db_rtb_c"
  }
}

# Public Route Table Association A
resource "aws_route_table_association" "public_route_table_association_a" {
  subnet_id      = aws_subnet.pub_a.id
  route_table_id = aws_route_table.pub_rtb_a.id
}

# Public Route Table Association C
resource "aws_route_table_association" "public_route_table_association_c" {
  subnet_id      = aws_subnet.pub_c.id
  route_table_id = aws_route_table.pub_rtb_c.id
}

# Private app Route Table Association A
resource "aws_route_table_association" "pri_association_a" {
  subnet_id      = aws_subnet.pri_app_a.id
  route_table_id = aws_route_table.pri_app_rtb_a.id
}

# Private app Route Table Association C
resource "aws_route_table_association" "pri_association_c" {
  subnet_id      = aws_subnet.pri_app_c.id
  route_table_id = aws_route_table.pri_app_rtb_c.id
}

# Private app Route Table Association A
resource "aws_route_table_association" "pri_db_association_a" {
  subnet_id      = aws_subnet.pri_db_a.id
  route_table_id = aws_route_table.pri_db_rtb_a.id
}

# Private app Route Table Association C
resource "aws_route_table_association" "pri_db_association_c" {
  subnet_id      = aws_subnet.pri_db_c.id
  route_table_id = aws_route_table.pri_db_rtb_c.id
}

# Create a EIP
resource "aws_eip" "nat_eip_a" {
  domain = "vpc"
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = "${var.naming}_eip_a"
  }
}

resource "aws_eip" "nat_eip_c" {
  domain = "vpc"
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = "${var.naming}_eip_c"
  }
}

# Create NAT Gatway
resource "aws_nat_gateway" "nat_a" {
  allocation_id = aws_eip.nat_eip_a.id
  subnet_id     = aws_subnet.pub_a.id
  tags = {
    Name = "${var.naming}_nat_a"
  }
}

resource "aws_nat_gateway" "nat_c" {
  allocation_id = aws_eip.nat_eip_c.id
  subnet_id     = aws_subnet.pub_c.id
  tags = {
    Name = "${var.naming}_nat_c"
  }
}

# Associate Public Subnet with Internet Gateway
resource "aws_route" "pub_r_a" {
  route_table_id         = aws_route_table.pub_rtb_a.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.def_igw.id
}

resource "aws_route" "pub_r_c" {
  route_table_id         = aws_route_table.pub_rtb_c.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.def_igw.id
}

# Associate Private Subnets with NAT Gateway
resource "aws_route" "pri_app_route_a" {
  route_table_id         = aws_route_table.pri_app_rtb_a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_a.id
}

resource "aws_route" "pri_app_route_c" {
  route_table_id         = aws_route_table.pri_app_rtb_c.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_c.id
}

resource "aws_route" "pri_db_route_a" {
  route_table_id         = aws_route_table.pri_db_rtb_a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_a.id
}

resource "aws_route" "pri_db_route_c" {
  route_table_id         = aws_route_table.pri_db_rtb_c.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_c.id
}
