terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.49.0"  # Aws provider version not terraform version
    }
  }
  backend "s3" {
    bucket = "devops-pract-dev-state"
    key = "catalogue"
    region = "us-east-1"
    dynamodb_table = "devops-pract-dev-locking"
  }
}

provider "aws" {
  region = "us-east-1"   
}