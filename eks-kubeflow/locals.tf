locals {
  region          = "us-east-1"
  vpc_name        = "${var.environment}-eks-vpc"
  azs             = ["us-east-1a", "us-east-1b"]
  vpc_cidr        = "10.0.0.0/16"
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
  db_subnets      = ["10.0.10.0/24", "10.0.11.0/24"]
  # dev_vpc_id                = "vpc-0842ddf786573e2f0"
  # dev_public_subnet1        = "subnet-0e559c2d6816582b3"
  # dev_public_subnet2        = "subnet-0ed4751a9dee442d5"
  # dev_private_subnet1       = "subnet-0a80414da45dc767e"
  # dev_private_subnet2       = "subnet-0c4edf2aa3ecdd7d0"
  # dev_db_subnet1            = "dbsubnet1"
  # wireguard_instance        = "t2.small"
  # wireguard_ami             = "ami-0fc5d935ebf8bc3bc"
  # wireguard_kp              = "wireguard_kp"
  # wireguard_eip             = "eipalloc-07e36461504a544f3"
  keycloak_user_password = var.KEYCLOAK_USER_PASSWORD
}
