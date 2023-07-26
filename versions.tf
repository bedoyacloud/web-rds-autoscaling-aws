terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "cloudops-labs-pragma"

  default_tags {
    tags = {
      terraform    = "true"
      client_name  = local.client_name
      project_name = local.project_name
      environment  = local.environment
      owner        = local.owner
    }
  }

}
