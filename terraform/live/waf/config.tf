terraform {

  cloud {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.27.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"

  default_tags {
    tags = local.common_tags
  }
}

