locals {
  region          = "us-east-1"
  vpc_name        = "${var.environment}-eks-vpc"
  azs             = ["us-east-1a", "us-east-1b"]
  vpc_cidr        = "10.0.0.0/16"
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_names = ["${var.environment}-eks-private-subnet-a","${var.environment}-eks-private-subnet-b"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
  public_subnet_names = ["${var.environment}-eks-public-subnet-a","${var.environment}-eks-public-subnet-b"]
  db_subnet_names = ["${var.environment}-eks-db-subnet-a","${var.environment}-eks-db-subnet-b"]
  db_subnets      = ["10.0.10.0/24", "10.0.11.0/24"]
  keycloak_user_password = var.KEYCLOAK_USER_PASSWORD
}
