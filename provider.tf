terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.66.1"
    }
  }
}

provider "aws" {
  # Configuration options
  profile = "default"
  region = "us-east-2"
}