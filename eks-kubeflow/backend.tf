terraform {
  backend "s3" {
    bucket = "seyi-eks-project"
    key    = "eks/eks-infrastructure/state"
    region = "us-east-1"
  }
}
