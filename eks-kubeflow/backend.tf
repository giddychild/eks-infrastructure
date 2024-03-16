terraform {
  backend "s3" {
    bucket = "srcd-mlops-aws-tfstate"
    key    = "terraform/srcd-mlops-aws-infra/state"
    region = "us-east-1"
  }
}
