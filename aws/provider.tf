provider "aws" {
  region = "us-east-1"
  profile = "default"
}

terraform {
  backend "s3" {
    bucket = "terraform-tfstate-projects-nacholee"
    key    = "terraform-wordpress/tfstate1"
    region = "us-east-1"
    profile = "default"
  }
  required_version = ">= 0.12"
}