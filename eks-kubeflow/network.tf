module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.vpc_name
  cidr = local.vpc_cidr

  azs              = local.azs
  private_subnets  = local.private_subnets
  private_subnet_names = local.private_subnet_names
  public_subnets   = local.public_subnets
  public_subnet_names = local.public_subnet_names
  database_subnets = local.db_subnets
  database_subnet_names = local.db_subnet_names

  create_database_subnet_group = true

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true
  
  public_subnet_tags = {
    Name = local.public_subnet_names
  }
  private_subnet_tags = {
    Name = local.private_subnet_names
  }
  database_subnet_tags = {
    Name = local.db_subnet_names
  }

  tags = {
    Environment = "${var.environment}"
    Name        = local.vpc_name
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = module.vpc.vpc_id
  service_name = "com.amazonaws.${local.region}.s3"
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id             = module.vpc.vpc_id
  service_name       = "com.amazonaws.${local.region}.ecr.api"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = module.vpc.private_subnets
  security_group_ids = [aws_security_group.ecr_sg.id]
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id             = module.vpc.vpc_id
  service_name       = "com.amazonaws.${local.region}.ecr.dkr"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = module.vpc.private_subnets
  security_group_ids = [aws_security_group.ecr_sg.id]
}

resource "aws_security_group" "ecr_sg" {
  name        = "ecr_sg"
  description = "Allow inbound traffic for ECR endpoint"
  vpc_id      = module.vpc.vpc_id

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
