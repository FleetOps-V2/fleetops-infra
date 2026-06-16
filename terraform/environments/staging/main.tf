terraform {
  backend "s3" {
    bucket         = "fleetops-terraform-state-johan"
    key            = "environments/staging/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "fleetops-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project     = "fleetops"
      Environment = "staging"
      ManagedBy   = "terraform"
    }
  }
}




