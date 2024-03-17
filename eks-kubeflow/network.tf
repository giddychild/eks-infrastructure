resource "aws_vpc" "main" {
  cidr_block = local.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "EKS-VPC"
  }
}

resource "aws_subnet" "public" {
  count = length(local.public_subnets)
  vpc_id = aws_vpc.main.id
  cidr_block = local.public_subnets[count.index]
  map_public_ip_on_launch = true
  availability_zone = element(local.azs, count.index)
  tags = {
    Name = "EKS-PublicSubnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count = length(local.private_subnets)
  vpc_id = aws_vpc.main.id
  cidr_block = local.private_subnets[count.index]
  availability_zone = element(local.azs, count.index)
  tags = {
    Name = "EKS-PrivateSubnet-${count.index + 1}"
  }
}

resource "aws_subnet" "db" {
  count = length(local.db_subnets)
  vpc_id = aws_vpc.main.id
  cidr_block = local.db_subnets[count.index]
  availability_zone = element(local.azs, count.index)
  tags = {
    Name = "EKS-DBSubnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "EKS-IGW"
  }
}

resource "aws_eip" "nat1" {
  domain = "vpc"
}

# resource "aws_eip" "nat2" {
#   domain = "vpc"
# }

resource "aws_nat_gateway" "nat1" {
  allocation_id = aws_eip.nat1.id
  subnet_id = aws_subnet.public[0].id
  tags = {
    Name = "EKS-NAT1"
  }
}

# resource "aws_nat_gateway" "nat2" {
#   allocation_id = aws_eip.nat2.id
#   subnet_id = aws_subnet.public[1].id
#   tags = {
#     Name = "EKS-NAT2"
#   }
# }

#   create_database_subnet_group = true

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "EKS-PublicRouteTable"
  }
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private_az1" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat1.id
  }
  tags = {
    Name = "EKS-PrivateRouteTable-AZ1"
  }
}

resource "aws_route_table" "private_az2" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat2.id
  }
  tags = {
    Name = "EKS-PrivateRouteTable-AZ2"
  }
}

resource "aws_route_table_association" "private_az1" {
  count          = length([for s in aws_subnet.private : s.id if s.availability_zone == "us-east-1a"])
  subnet_id      = [for s in aws_subnet.private : s.id if s.availability_zone == "us-east-1a"][count.index]
  route_table_id = aws_route_table.private_az1.id
}

resource "aws_route_table_association" "private_az2" {
  count          = length([for s in aws_subnet.private : s.id if s.availability_zone == "us-east-1b"])
  subnet_id      = [for s in aws_subnet.private : s.id if s.availability_zone == "us-east-1b"][count.index]
  route_table_id = aws_route_table.private_az2.id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${local.region}.s3"
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id             = aws_vpc.main.id
  service_name       = "com.amazonaws.${local.region}.ecr.api"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.ecr_sg.id]
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id             = aws_vpc.main.id
  service_name       = "com.amazonaws.${local.region}.ecr.dkr"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.ecr_sg.id]
}

resource "aws_security_group" "ecr_sg" {
  name        = "ecr_sg"
  description = "Allow inbound traffic for ECR endpoint"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.16.0/20"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

