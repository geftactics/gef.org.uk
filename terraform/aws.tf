terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
  backend "s3" {
  }
}

provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias = "virginia"
  region = "us-east-1"
}
